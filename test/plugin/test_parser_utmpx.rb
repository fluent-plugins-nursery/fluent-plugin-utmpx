require "helper"
require "fluent/plugin/in_tail"
require "fluent/plugin/parser_utmpx"

class UtmpxParserTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
    cleanup_directory(TMP_DIR)
  end

  teardown do
    cleanup_directory(TMP_DIR)
    Fluent::Engine.stop
  end

  CONFIG = config_element('ROOT')

  TMP_DIR = File.dirname(__FILE__) + "/../tmp/tail#{ENV['TEST_ENV_NUMBER']}"

  sub_test_case "configure" do
    def test_missing_parser
      assert_raise Fluent::ConfigError.new("<parse> section is required.") do
        create_driver(CONFIG)
      end
    end

    def test_unknown_parser
      assert_raise Fluent::ConfigError.new("Unknown parser plugin 'unknown'. Run 'gem search -rd fluent-plugin' to find plugins") do
        create_driver(utmpx_config_element("", "unknown"))
      end
    end
  end

  sub_test_case "parse wtmp,utmp" do
    def test_empty_record
      Tempfile.create do |f|
        d = create_driver(utmpx_config_element(f.path))
        d.run
        assert_equal(0, d.events.size)
      end
    end
  end

  private

  def utmpx_config_element(path = "", parser = "utmpx")
    CONFIG + config_element("", "", { "@type" => "tail",
                                      "path" => path,
                                      "tag" => "utmpx" }, [
                              config_element("parse", "", {
                                               "@type" => parser
                                             })
                            ])
  end

  def create_parser(conf)
    Fluent::Test::Driver::Parser.new(Fluent::Plugin::UtmpxParser).configure(conf)
  end

  def create_driver(conf)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::TailInput).configure(conf)
  end

  def cleanup_directory(path)
    unless Dir.exist?(path)
      FileUtils.mkdir_p(path)
      return
    end
    begin
      FileUtils.rm_f(path, secure:true)
    rescue ArgumentError
      FileUtils.rm_f(path) # For Ruby 2.6 or before.
    end
    if File.exist?(path)
      FileUtils.remove_entry_secure(path, true)
    end
    FileUtils.mkdir_p(path)
  end
end
