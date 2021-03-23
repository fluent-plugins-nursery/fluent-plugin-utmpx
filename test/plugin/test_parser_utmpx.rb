require "helper"
require "fluent/plugin/parser_utmpx.rb"

class UtmpxParserTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Parser.new(Fluent::Plugin::UtmpxParser).configure(conf)
  end
end
