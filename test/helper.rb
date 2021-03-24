$LOAD_PATH.unshift(File.expand_path("../../", __FILE__))
require "test-unit"
require "fluent/test"
require "fluent/test/driver/parser"
require "fluent/test/driver/input"
require "fluent/test/helpers"
require "linux/utmpx"

Test::Unit::TestCase.include(Fluent::Test::Helpers)
Test::Unit::TestCase.extend(Fluent::Test::Helpers)

def dump_fixture_path(name)
  File.join(File.dirname(__FILE__),
            "fixtures",
            "#{name}.dump")
end
