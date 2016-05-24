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
    require 'zip'
    ver = '1.5'
    source = 'https://github.com/kyz/libmspack/archive/v' + ver +'.zip'
    target = './ext/'
    archivedir = 'libmspack-' + ver
    URI.parse(source).open do |tempfile|
        Zip.on_exists_proc = true
        Zip::File.open(tempfile.path) do |file|
            file.each do |entry|
                path = target + entry.name
                FileUtils.mkdir_p(File.dirname(path))
                file.extract(entry, path)
            end
        end
    end
    FileUtils.rm_rf(target + 'libmspack')
    FileUtils.mv(target + archivedir + '/libmspack/trunk/', target + 'libmspack')
    File.delete(target + 'libmspack/mspack/debug.c')
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
