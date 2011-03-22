require "bundler"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
require "rcov" if RUBY_ENGINE == "ruby" && RUBY_VERSION[0..2] == "1.8"

RSpec::Core::RakeTask.new(:rspec)

task :default => :rspec

desc  "Run all specs with rcov"
RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rcov = true
  t.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/}
end

desc "Clean-up temporary files (Rubinius compiled files, etc...)"
task :cleanup do
  `find . -name "*.rbc" | xargs rm -f`
  puts "temporary files deleted"
end
