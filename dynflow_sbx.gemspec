# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dynflow_sbx/version'

Gem::Specification.new do |spec|
  spec.name          = "dynflow_sbx"
  spec.version       = DynflowSbx::VERSION
  spec.authors       = ["Erik Nelson"]
  spec.email         = ["erik@nsk.io"]

  spec.summary       = %q{This is a summary}
  spec.description   = %q{This is a description}
  spec.homepage      = "https://www.github.com/eriknelson/dynflow_sbx"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sqlite3"
  spec.add_dependency "sequel"
  spec.add_dependency "sinatra"
  spec.add_dependency "dynflow", "0.8.11"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
