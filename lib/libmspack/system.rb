module LibMsPack
    module RubySystem

        MsPack::RubyPackSystem.open = FFI::Function.new(MsPack::MsPackFile.ptr, [ MsPack::MsPackSystem.ptr, :string, :int ]) do |system, filename, mode|
            case mode
            when LibMsPack::MSPACK_SYS_OPEN_READ
                fmode = "rb"
            when LibMsPack::MSPACK_SYS_OPEN_WRITE
                fmode = "wb"
            when LibMsPack::MSPACK_SYS_OPEN_UPDATE
                fmode = "r+b"
            when LibMsPack::MSPACK_SYS_OPEN_APPEND
                fmode = "ab"
            else
                return nil
            end

            file = MsPack::MsPackFile.new
            file.name = filename
            file.file = File.new(filename, fmode)
            file
        end

        MsPack::RubyPackSystem.close = FFI::Function.new(:void, [ MsPack::MsPackFile.ptr ]) do |file|
            return nil unless file
            file.file.close if file.file
            file.file = nil
            file.name = nil
            file = nil
        end

        MsPack::RubyPackSystem.read = FFI::Function.new(:int, [ MsPack::MsPackFile.ptr, :buffer_inout, :int ]) do |file, buffer, bytes|
            return -1 if file.nil? or buffer.nil? or bytes.nil? or bytes < 0
            file.file.read(bytes, buffer)
        end

        MsPack::RubyPackSystem.write = FFI::Function.new(:int, [ MsPack::MsPackFile.ptr, :buffer_inout, :int ]) do |file, buffer, bytes|
            return -1 if file.nil? or buffer.nil? or bytes.nil? or bytes < 0
            file.file.write(buffer.get_string(bytes))
        end

        MsPack::RubyPackSystem.seek = FFI::Function.new(:int, [ MsPack::MsPackFile.ptr, :off_t, :int ]) do |file, offset, mode|
            return nil unless file
            case mode
            when LibMsPack::MSPACK_SYS_SEEK_START
                fmode = IO::SEEK_START
            when LibMsPack::MSPACK_SYS_SEEK_CUR
                fmode = IO::SEEK_CUR
            when LibMsPack::MSPACK_SYS_SEEK_END
                fmode = IO::SEEK_END
            else
                return nil
            end
            file.file.seek(offset, fmode)
        end

        MsPack::RubyPackSystem.tell = FFI::Function.new(:int, [ MsPack::MsPackFile.ptr ]) do |file|
            return nil unless file
            file.tell
        end

        MsPack::RubyPackSystem.message = FFI::Function.new(:int, [ MsPack::MsPackFile.ptr, :string, :varargs ]) do |file, format, vars|
            $stderr.puts file.name if file
            $stderr.printf(format, vars)
            $stderr.puts
            $stderr.flush
        end

        MsPack::RubyPackSystem.alloc = FFI::Function.new(:pointer, [ :size_t ]) do |bytes|
            FFI::MemoryPointer.new(bytes)
        end

        MsPack::RubyPackSystem.free = FFI::Function.new(:void, [ :pointer ]) do |buffer|
            buffer.free
            buffer = nil
        end

        MsPack::RubyPackSystem.copy = FFI::Function.new(:void, [ :buffer_in, :buffer_out, :size_t ]) do |src, dst, bytes|
            dst.write_string(src.read_string(bytes), bytes)
        end

        MsPack::RubyPackSystem.copy = nil
    end
end
