require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  filepath = File.expand_path('test/test_loader.rb', __dir__)
  t.ruby_opts << "-r #{filepath}"

  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

desc 'Clear out compiled files'
task :clear do
  `rm -r .iseq`
end
