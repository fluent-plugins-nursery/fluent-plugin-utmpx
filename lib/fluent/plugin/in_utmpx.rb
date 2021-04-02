#
# Copyright 2021- Kentaro Hayashi
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "fluent/version"
require "fluent/plugin/input"
require "fluent/plugin/in_tail/position_file"
require 'fluent/variable_store'
require "linux/utmpx"

Fluent::FileWrapper = File

module Fluent
  module Plugin

    TargetInfo = Struct.new(:path, :ino)

    class UtmpxInput < Fluent::Plugin::Input
      Fluent::Plugin.register_input("utmpx", self)

      helpers :timer

      desc "Path to wtmp,utmp"
      config_param :path, :string
      desc "Tag string"
      config_param :tag, :string
      desc "Interval to check `path` (N seconds)"
      config_param :interval, :integer, default: 10
      desc "Record the position it last read into this file"
      config_param :pos_file, :string

      def configure(conf)
        @variable_store = Fluent::VariableStore.fetch_or_build(:in_utmpx)
        super
        @utmpx = Linux::Utmpx::UtmpxParser.new
        @buffer = ""
        @tail_position = 0
        @previous_position = 0

        if @variable_store.key?(@pos_file) && !called_in_test?
          plugin_id_using_this_path = @variable_store[@pos_file]
          raise Fluent::ConfigError, "Other 'in_utmpx' plugin already use same pos_file path: plugin_id = #{plugin_id_using_this_path}, pos_file path = #{@pos_file}"
        end
        @variable_store[@pos_file] = self.plugin_id
      end

      def start
        super

        pos_file_dir = File.dirname(@pos_file)
        FileUtils.mkdir_p(pos_file_dir, mode: Fluent::DEFAULT_DIR_PERMISSION) unless Dir.exist?(pos_file_dir)
        @pf_file = File.open(@pos_file, File::RDWR|File::CREAT|File::BINARY, Fluent::DEFAULT_FILE_PERMISSION)
        @pf_file.sync = true
        target_info = TargetInfo.new(@path, Fluent::FileWrapper.stat(@path).ino)
        if Gem::Version.new(Fluent::VERSION) < Gem::Version.new("1.12.0")
          @pf = TailInput::PositionFile.load(@pf_file, logger: log)
        else
          @pf = TailInput::PositionFile.load(@pf_file, false, {target_info.path => target_info}, logger: log)
        end

        timer_execute(:execute_utmpx, @interval, &method(:refresh_watchers))
      end

      def refresh_watchers
        @tail_position = Fluent::FileWrapper.stat(@path).size
        if Gem::Version.new(Fluent::VERSION) < Gem::Version.new("1.12.0")
          @pe = @pf[@path]
        else
          @pe = @pf[TargetInfo.new(@path, Fluent::FileWrapper.stat(@path).ino)]
        end
        return if (@tail_position - @pe.read_pos) == 0

        if (@tail_position - @pe.read_pos) < 0
          # may be truncated, read from head
          @pe.update_pos(0)
          log.warn("#{@path} may be truncated")
          return
        end

        count = (@tail_position - @pe.read_pos) / @utmpx.num_bytes
        es = MultiEventStream.new
        File.open(@path) do |io|
          io.seek(@pe.read_pos)
          count.times do |n|
            time, record = parse_entry(@utmpx.read(io))
            es.add(time,record)
          end
          @pe.update_pos(@pe.read_pos + count * @utmpx.num_bytes)
          router.emit_stream(@tag, es)
        end
      end

      def shutdown
        @pf_file.close if @pf_file
      end

      private

      def parse_entry(entry)
        record = {
          user: entry.user.dup,
          type: entry.type.dup,
          pid: entry.pid.to_i,
          line: entry.line.dup,
          host: entry.host.dup
        }
        [entry.time, record]
      end
    end
  end
end
