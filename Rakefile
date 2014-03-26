require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

desc 'Default: run specs.'
task :default => :spec

desc 'Run specs'
RSpec::Core::RakeTask.new(:spec) do |t|
end

YARD::Rake::YardocTask.new(:doc) do |t|
end

desc 'Download libmspack source code'
task :libmspack do
    require 'svn/downloader'
    repo = 'http://svn.code.sf.net/p/libmspack/code/libmspack/trunk/'
    path = './ext/libmspack/'
    SVN::Downloader.download(repo, path)
    File.delete(path + 'mspack/debug.c')
end

desc 'Compile libmspack source code'
task :compile do
    require 'ffi'
    require 'ffi-compiler/platform'
    Dir.chdir('./ext/') do
        `rake`
        system = FFI::Compiler::Platform.system
        dir = "#{system.arch}-#{system.os}"
        Dir["#{dir}/*.o"].each { |file| File.delete(file) }
    end
end
