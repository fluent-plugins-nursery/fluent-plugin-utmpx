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

  sub_test_case "parser driver" do
    def test_parser_type
      d = create_parser(utmpx_parser_config)
      assert_equal(:binary, d.instance.parser_type)
    end

    def test_parse
      d = create_parser(utmpx_parser_config)
      data = File.read(dump_fixture_path("alice_login"))
      d.instance.parse(data) do |time,record|
        # TODO: time
        expected = {
          type: :USER_PROCESS,
          user: "alice",
          pid: 121110,
          line: "tty7",
          host: ":0"
        }
        assert_equal(expected, record)
      end
    end
  end

  private

  def wtmp_path
    File.join(TMP_DIR, "wtmp")
  end

  def create_wtmp(path = "#{TMP_DIR}/wtmp")
    File.open(path, "wb") do |io|
      utmpx = Linux::Utmpx::UtmpxParser.new(
        type: Linux::Utmpx::Type::LOGIN_PROCESS
      )
      utmpx.write(io)
    end
  end

  def utmpx_parser_config(path = "", parser = "utmpx")
    CONFIG + config_element("", "", { "@type" => parser })
  end

  def utmpx_config_element(path = "", parser = "utmpx")
    CONFIG + config_element("", "", { "@type" => "tail",
                                      "path" => path,
                                      "tag" => "utmpx",
                                      "read_from_head" => "true"}, [
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
