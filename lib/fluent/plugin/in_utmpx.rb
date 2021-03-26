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

require "fluent/plugin/input"
require "fluent/plugin/parser"
require "linux/utmpx"

module Fluent
  module Plugin
    class UtmpxInput < Fluent::Plugin::Input
      Fluent::Plugin.register_input("utmpx", self)

      helpers :timer

      desc "Path to wtmp,utmp"
      config_param :path, :string
      desc "Tag string"
      config_param :tag, :string
      desc "Interval to check wtmp/utmp (N seconds)"
      config_param :interval, :integer, default: 10

      def configure(conf)
        super
        @utmpx = Linux::Utmpx::UtmpxParser.new
        @buffer = ""
        @tail_position = 0
        @previous_position = 0
      end

      def start
        super

        timer_execute(:execute_utmpx, @interval) do
          @tail_position = File.stat(@path).size
          File.open(@path) do |io|
            io.seek(@previous_position)
            count = (@tail_position - @previous_position) / @utmpx.num_bytes
            es = MultiEventStream.new
            count.times do |n|
              time, record = parse_entry(@utmpx.read(io))
              es.add(time,record)
            end
            @previous_position += count * @utmpx.num_bytes
            router.emit_stream(@tag, es)
          end
        end
      end

      def multi_workers_ready?
        false
      end

      private

      def parse_entry(entry)
        record = {
          user: entry.user,
          type: entry.type,
          pid: entry.pid.to_i,
          line: entry.line,
          host: entry.host
        }
        [entry.time, record]
      end
    end
  end
end
