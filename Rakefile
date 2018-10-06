require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)

# Set up the 'rubocop' RakeTask
RuboCop::RakeTask.new

task spec: :rubocop
task default: :spec
