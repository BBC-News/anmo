require "bundler/gem_tasks"
require "cucumber"
require "cucumber/rake/task"

task :default => [:test, :features]

task :test do
  Dir.glob("test/**/*_test.rb").each do |f|
    require File.expand_path(File.join(File.dirname(__FILE__), f))
  end
end

task :run do
  require "anmo"
  Anmo.launch_server 1234
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end
