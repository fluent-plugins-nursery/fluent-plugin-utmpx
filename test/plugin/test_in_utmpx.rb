require "helper"
require "fluent/plugin/in_utmpx"

class UtmpxInputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
    cleanup_directory(TMP_DIR)
  end

  teardown do
    cleanup_directory(TMP_DIR)
    Fluent::Engine.stop
  end

  CONFIG = config_element('ROOT')

  TMP_DIR = File.expand_path(File.dirname(__FILE__) + "/../tmp/utmpx")

  sub_test_case "configure" do
    def test_missing_path
      assert_raise Fluent::ConfigError.new("'path' parameter is required") do
        create_driver(CONFIG + config_element("", "", { "tag" => "utmpx",
                                                        "pos_file" => "wtmp.pos" }))
      end
    end

    def test_missing_tag
      assert_raise Fluent::ConfigError.new("'tag' parameter is required") do
        create_driver(CONFIG + config_element("", "", { "path" => "/var/log/wtmp",
                                                        "pos_file" => "wtmp.pos" }))
      end
    end

    def test_missing_pos_file
      assert_raise Fluent::ConfigError.new("'pos_file' parameter is required") do
        create_driver(CONFIG + config_element("", "", { "path" => "/var/log/wtmp",
                                                        "tag" => "wtmp" }))
      end
    end

    def test_default_parameters
      d = create_driver(utmpx_config)
      assert_equal("", d.instance.path)
      assert_equal("utmpx", d.instance.tag)
      assert_equal(10, d.instance.interval)
      assert_equal(utmpx_pos_path, d.instance.pos_file)
    end
  end

  sub_test_case "parse wtmp/utmp" do
    def test_one_record
      FileUtils.touch(wtmp_path)
      d = create_driver(utmpx_config(wtmp_path))
      d.run(expect_emits: 1) do
        append_utmpx
      end
      assert_equal(1, d.events.size)
    end

    def test_multiple_records
      FileUtils.touch(wtmp_path)
      d = create_driver(utmpx_config(wtmp_path))
      d.run(expect_emits: 1) do
        File.open(wtmp_path, "ab") do |io|
          3.times do
            append_utmpx
          end
        end
      end
      assert_equal(3, d.events.size)
    end

    def test_append_record
      create_wtmp
      d = create_driver(utmpx_config(wtmp_path))
      d.run(expect_emits: 1) do
        append_utmpx
      end
      assert_equal(2, d.events.size)
    end

    def test_pos_file
      create_wtmp
      @tail_position = Fluent::FileWrapper.stat(wtmp_path).size
      File.open(utmpx_pos_path, "w+") do |file|
        target_info = Fluent::Plugin::TailInput::TargetInfo.new(wtmp_path, Fluent::FileWrapper.stat(wtmp_path).ino)
        @pf = Fluent::Plugin::TailInput::PositionFile.new(file, false, {wtmp_path => target_info}, logger: nil)
        @pe = @pf[target_info]
        @pe.update_pos(@tail_position)
      end
      d = create_driver(utmpx_config(wtmp_path))
      d.run(expect_emits: 1) do
        File.open(wtmp_path, "ab") do |io|
          utmpx = Linux::Utmpx::UtmpxParser.new(
            type: Linux::Utmpx::Type::LOGIN_PROCESS,
            user: "alice"
          )
          utmpx.write(io)
        end
      end
      assert_equal(1, d.events.size)
    end
  end

  private

  def wtmp_path
    File.join(TMP_DIR, "wtmp")
  end

  def utmpx_pos_path
    File.join(TMP_DIR, "utmpx.pos")
  end

  def create_wtmp(path = "#{TMP_DIR}/wtmp")
    File.open(path, "wb") do |io|
      utmpx = Linux::Utmpx::UtmpxParser.new(
        ut_type: Linux::Utmpx::Type::LOGIN_PROCESS,
        ut_user: "alice",
        ut_pid: 10000,
        ut_line: "pts/1",
        ut_host: "localhost"
      )
      utmpx.write(io)
    end
  end

  def utmpx_config(path = "", input = "utmpx", tag = "utmpx", pos_file = "#{TMP_DIR}/utmpx.pos" )
    CONFIG + config_element("", "", { "@type" => input,
                                      "path" => path,
                                      "tag" => tag,
                                      "pos_file" => pos_file })
  end

  def append_utmpx(path: wtmp_path, type: Linux::Utmpx::Type::LOGIN_PROCESS, user: "alice", host: "localhost", line: "pts/1", pid: 10000)
    File.open(path, "ab") do |io|
      utmpx = Linux::Utmpx::UtmpxParser.new(
        ut_type: type,
        ut_user: user,
        ut_pid: pid,
        ut_line: line,
        ut_host: host
      )
      utmpx.write(io)
    end
  end

  def create_driver(conf)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::UtmpxInput).configure(conf)
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
