require "bundler/gem_tasks"

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

GIT_REMOTES = %w(origin github)

task :push_all do
  GIT_REMOTES.each do |remote|
    system "git push #{remote} master"
    system "git push #{remote} master --tags"
  end
end

task :default => :spec