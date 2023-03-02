lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-utmpx"
  spec.version = "0.5.0"
  spec.authors = ["Kentaro Hayashi"]
  spec.email   = ["kenhys@gmail.com"]

  spec.summary       = %q{Fluentd Input plugin to parse login records}
  spec.description   = %q{Fluentd Input plugin to parse /var/log/wtmp,/var/run/utmp}
  spec.homepage      = "https://github.com/fluent-plugins-nursery/fluent-plugin-utmpx"
  spec.license       = "Apache-2.0"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "linux-utmpx", "~> 0.3.0"
  spec.add_runtime_dependency "fluentd", [">= 1.14.0", "< 2"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit", "~> 3.5"
  spec.add_development_dependency "webrick"
end
