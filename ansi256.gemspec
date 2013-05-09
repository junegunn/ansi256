# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ansi256/version'

Gem::Specification.new do |spec|
  spec.name          = "ansi256"
  spec.version       = Ansi256::VERSION
  spec.authors       = ["Junegunn Choi"]
  spec.email         = ["junegunn.c@gmail.com"]
  spec.description   = %q{Colorize text using 256-color ANSI codes}
  spec.summary       = %q{Colorize text using 256-color ANSI codes}
  spec.homepage      = "https://github.com/junegunn/ansi256"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
