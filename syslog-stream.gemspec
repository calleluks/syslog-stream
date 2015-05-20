lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "syslog/stream/version"

Gem::Specification.new do |spec|
  spec.name = "syslog-stream"
  spec.version = Syslog::Stream::VERSION
  spec.authors = ["Calle Erlandsson"]
  spec.email = ["calle@calleerlandsson.com"]

  spec.summary = "Parse streams of RFC5424 Syslog messages"
  spec.homepage = "https://github.com/calleerlandsson/syslog-stream/"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^test/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency "syslog-parser"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
