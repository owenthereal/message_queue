# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'message_queue/version'

Gem::Specification.new do |spec|
  spec.name          = "message_queue"
  spec.version       = MessageQueue::VERSION
  spec.authors       = ["Jingwen Owen Ou"]
  spec.email         = ["jingweno@gmail.com"]
  spec.description   = %q{A common interface to multiple message queues libraries.}
  spec.summary       = %q{A common interface to multiple message queues libraries.}
  spec.homepage      = "https://github.com/jingweno/message_queue"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
end
