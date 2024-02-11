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
    require 'open-uri'
    version = '0.11alpha'
    source = "https://www.cabextract.org.uk/libmspack/libmspack-#{version}.tar.gz"
    target = './ext/'
    archivedir = 'libmspack-' + version
    URI(source).open do |tempfile|
        system('tar', '-C', target, '-xf', tempfile.path)
    end
    FileUtils.rm_rf(target + 'libmspack')
    FileUtils.mv(target + archivedir, target + 'libmspack')
    FileUtils.rm_rf(target + archivedir)
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
