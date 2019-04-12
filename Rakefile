require "rake/testtask"

desc 'Run test_unit'
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
  t.options = "-v"
end

task :default => :test

task :run do
  sh 'ruby.exe lib/main.rb'
end

