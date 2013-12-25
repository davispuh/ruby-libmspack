module LibMsPack
    module MsPack
        module Constants
            # Pass to #Version to get the overall library version.
            MSPACK_VER_LIBRARY = 0
            # Pass to #Version to get the MsPackSystem version.
            MSPACK_VER_SYSTEM = 1
            # Pass to #Version to get the MsCabDecompressor version.
            MSPACK_VER_MSCABD = 2
            # Pass to #Version to get the MsCabCompressor version.
            MSPACK_VER_MSCABC = 3
            # Pass to #Version to get the MsChmDecompressor version.
            MSPACK_VER_MSCHMD = 4
            # Pass to #Version to get the MsChmCompressor version.
            MSPACK_VER_MSCHMC = 5
            # Pass to #Version to get the MsLitDecompressor version.
            MSPACK_VER_MSLITD = 6
            # Pass to #Version to get the MsLitCompressor version.
            MSPACK_VER_MSLITC = 7
            # Pass to #Version to get the MsHlpDecompressor version.
            MSPACK_VER_MSHLPD = 8
            # Pass to #Version to get the MsHlpCompressor version.
            MSPACK_VER_MSHLPC = 9
            # Pass to #Version to get the MsSzddDecompressor version.
            MSPACK_VER_MSSZDDD = 10
            # Pass to #Version to get the MsSzddCompressor version.
            MSPACK_VER_MSSZDDC = 11
            # Pass to #Version to get the MsKwajDecompressor version.
            MSPACK_VER_MSKWAJD = 12
            # Pass to #Version to get the MsKwajCompressor version.
            MSPACK_VER_MSKWAJC = 13
            # Pass to #Version to get the MsOabDecompressor version.
            MSPACK_VER_MSOABD = 14
            # Pass to #Version to get the MsOabCompressor version.
            MSPACK_VER_MSOABC = 15

            # MsPackSystem#open mode: open existing file for reading
            MSPACK_SYS_OPEN_READ = 0
            # MsPackSystem#open mode: open new file for writing
            MSPACK_SYS_OPEN_WRITE = 1
            # MsPackSystem#open mode: open existing file for writing
            MSPACK_SYS_OPEN_UPDATE = 2
            # MsPackSystem#open mode: open existing file for writing
            MSPACK_SYS_OPEN_APPEND = 3

            # MsPackSystem#seek mode: seek relative to start of file
            MSPACK_SYS_SEEK_START = 0
            # MsPackSystem#seek mode: seek relative to current offset
            MSPACK_SYS_SEEK_CUR = 1
            # MsPackSystem#seek mode: seek relative to end of file
            MSPACK_SYS_SEEK_END = 2

            # Error code: no error.
            MSPACK_ERR_OK = 0
            # Error code: bad arguments to method.
            MSPACK_ERR_ARGS = 1
            # Error code: error opening file.
            MSPACK_ERR_OPEN = 2
            # Error code: error reading file.
            MSPACK_ERR_READ = 3
            # Error code: error writing file.
            MSPACK_ERR_WRITE = 4
            # Error code: seek error.
            MSPACK_ERR_SEEK = 5
            # Error code: out of memory.
            MSPACK_ERR_NOMEMORY = 6
            # Error code: bad "magic id" in file.
            MSPACK_ERR_SIGNATURE = 7
            # Error code: bad or corrupt file format.
            MSPACK_ERR_DATAFORMAT = 8
            # Error code: bad checksum or CRC.
            MSPACK_ERR_CHECKSUM = 9
            # Error code: error during compression.
            MSPACK_ERR_CRUNCH = 10
            # Error code: error during decompression.
            MSPACK_ERR_DECRUNCH = 11
        end

        # A structure which represents an open file handle.
        #
        # The contents of this structure are determined by the implementation of the MsPackSystem#open method.
        class MsPackFile < FFI::Struct
            layout({
                :file => :int,
                :name => :string
            })

            def file=(file)
                self[:file] = file
            end

            def file
                self[:file]
            end

            def name
                self[:name]
            end
        end

        # A structure which abstracts file I/O and memory management.
        #
        # The library always uses the MsPackSystem structure for interaction with the file system and to allocate, free and copy all memory. It also uses it to send literal messages to the library user.
        #
        # When the library is compiled normally, passing nil to a compressor or decompressor constructor will result in a default MsPackSystem being used, where all methods are implemented with the standard C library. However, all constructors support being given a custom created MsPackSystem structure, with the library user's own methods. This allows for more abstract interaction, such as reading and writing files directly to memory, or from a network socket or pipe.
        #
        # Implementors of an MsPackSystem structure should read all documentation entries for every structure member, and write methods which conform to those standards.
        class MsPackSystem < FFI::Struct

            layout({
                :open => callback([ MsPackSystem.ptr, :string, :int ], MsPackFile.ptr),
                :close => callback([ MsPackFile.ptr ], :void),
                :read => callback([ MsPackFile.ptr, :buffer_inout, :int ], :int),
                :write => callback([ MsPackFile.ptr, :buffer_inout, :int ], :int),
                :seek => callback([ MsPackFile.ptr, :off_t, :int ], :int),
                :tell => callback([ MsPackFile.ptr ], :off_t),
                :message => callback([ MsPackFile.ptr, :string, :varargs ], :void),
                :alloc => callback([ MsPackFile.ptr, :size_t ], :pointer),
                :free => callback([ :pointer ], :void),
                :copy => callback([:buffer_in, :buffer_out, :size_t ], :void),
                :null_ptr => :pointer
            })

            def open=(cb)
                self[:open] = cb
            end

            def open
                self[:open]
            end

            def close=(cb)
                self[:close] = cb
            end

            def close
                self[:close]
            end

            def read=(cb)
                self[:read] = cb
            end

            def read
                self[:read]
            end

            def write=(cb)
                self[:write] = cb
            end

            def write
                self[:write]
            end

            def seek=(cb)
                self[:seek] = cb
            end

            def seek
                self[:seek]
            end

            def tell=(cb)
                self[:tell] = cb
            end

            def tell
                self[:tell]
            end

            def message=(cb)
                self[:message] = cb
            end

            def message
                self[:message]
            end

            def alloc=(cb)
                self[:alloc] = cb
            end

            def alloc
                self[:alloc]
            end

            def free=(cb)
                self[:free] = cb
            end

            def free
                self[:free]
            end

            def copy=(cb)
                self[:copy] = cb
            end

            def copy
                self[:copy]
            end

        end

        RubyPackSystem = MsPackSystem.new
    end
end
