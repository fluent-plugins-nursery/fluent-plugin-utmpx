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

require "fluent/plugin/parser"
require "linux/utmpx"

module Fluent
  module Plugin
    class UtmpxParser < Fluent::Plugin::Parser
      Fluent::Plugin.register_parser("utmpx", self)

      def configure(conf)
        super
        @utmpx_parser = Linux::Utmpx::UtmpxParser.new
      end

      def parser_type
        :binary
      end

      def parse(data, &block)
        obj = BinData::DelayedIO.new(type: UtmpxParser, read_abs_offset: 0)
        (data.size / obj.num_bytes).times.each do |i|
          obj.read(data.byteslice(i * obj.num_bytes, obj.num_bytes)) do
            obj.read_now!
            time, record = parse_entry(obj)
            yield time, record
          end
        end
      end

      def parse_io(io, &block)
        while !io.eof?
          entry = @utmpx_parser.read(io)
          time, record = parse_entry(entry)
          yield time, record
        end
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
        convert_values(parse_time(entry.time),record)
      end
    end
  end
end
