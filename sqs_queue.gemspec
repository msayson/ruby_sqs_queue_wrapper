lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'ruby_sqs_queue_wrapper'
  spec.version       = '0.1.0'
  spec.authors       = ['Mark Sayson']
  spec.email         = ['masayson@gmail.com']

  spec.summary       = 'A wrapper library for the AWS SQS queue.'
  spec.homepage      = 'https://github.com/msayson/ruby_sqs_queue_wrapper'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Dependencies required for the gem to be used by downstream consumers
  spec.add_runtime_dependency 'aws-sdk-sqs', '~> 1.3.0'

  # Dependencies only used for development/testing
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.59'
end
