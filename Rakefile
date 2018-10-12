require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yaml'

desc 'Run unit tests'
RSpec::Core::RakeTask.new(:spec)

desc 'Run integration tests'
RSpec::Core::RakeTask.new(:integ) do |t|
  t.pattern = 'integ/**/*integ_spec.rb'

  load_integ_environment_vars
end

desc 'Run RuboCop style check'
RuboCop::RakeTask.new
task spec: :rubocop
task integ: :rubocop

task default: %i[rubocop spec]

private

# Load ENV variables for integration tests
def load_integ_environment_vars
  env_file = File.join(__dir__, 'config/local_env_integ.yml')
  env_key_vals = YAML.load_file(env_file)
  %w[
    SqsQueueIntegTests_QueueUrl
    SqsQueueIntegTests_QueueRegion
    SqsQueueIntegTests_AccessId
    SqsQueueIntegTests_SecretKey
  ].each { |var| ENV[var] = env_key_vals.fetch(var) }
end
