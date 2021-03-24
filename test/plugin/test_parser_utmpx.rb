require "helper"
require "fluent/plugin/parser_utmpx"

class UtmpxParserTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  CONFIG = config_element('ROOT')

  sub_test_case "configure" do
    def test_missing_parser
      assert_raise(Fluent::ConfigError) do
        create_driver(CONFIG)
      end
    end

    def test_unknown_parser
      assert_raise(Fluent::ConfigError) do
        create_driver(utmpx_config_element("", "unknown"))
      end
    end
  end

  private

  def utmpx_config_element(path = "", parser = "utmpx")
    CONFIG + config_element("", "", { "@type" => "tail",
                                      "path" => path }, [
                              config_element("parse", "", {
                                               "@type" => parser
                                             })
                            ])
  end

  def create_driver(conf)
    Fluent::Test::Driver::Parser.new(Fluent::Plugin::UtmpxParser).configure(conf)
  end
end
