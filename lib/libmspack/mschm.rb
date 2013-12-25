module LibMsPack
    module MsChm
        module Constants

            MSCHMC_ENDLIST = 0
            MSCHMC_UNCOMP = 1
            MSCHMC_MSCOMP = 2

            MSCHMC_PARAM_TIMESTAMP = 0
            MSCHMC_PARAM_LANGUAGE = 1
            MSCHMC_PARAM_LZXWINDOW = 2
            MSCHMC_PARAM_DENSITY = 3
            MSCHMC_PARAM_INDEX = 4

        end

        class MsChmcFile < FFI::Struct
            layout({
                :section => :int,
                :filename => :string,
                :chm_filename => :string,
                :length => :off_t
            })

            def section
                self[:section]
            end

            def filename
                self[:filename]
            end

            def chm_filename
                self[:chm_filename]
            end

            def length
                self[:length]
            end
        end

        class MsChmdHeader < FFI::Struct
        end

        class MsChmdSection < FFI::Struct
            layout({
                :chm => MsChmdHeader.ptr,
                :id => :uint
            })

            def chm
                return nil if self[:chm].pointer.address.zero?
                self[:chm]
            end

            def id
                self[:id]
            end
        end

        class MsChmdFile < FFI::Struct
            layout({
                :next => MsChmdFile.ptr,
                :section => MsChmdSection.ptr,
                :offset => :off_t,
                :length => :off_t,
                :filename => :string
            })

            def next
                return nil if self[:next].pointer.address.zero?
                self[:next]
            end

            def section
                return nil if self[:section].pointer.address.zero?
                self[:section]
            end

            def offset
                self[:offset]
            end

            def length
                self[:length]
            end

            def filename
                self[:filename]
            end
        end

        class MsChmdSecUncompressed < FFI::Struct
            layout({
                :base => MsChmdSection,
                :offset => :off_t
            })

            def base
                self[:base]
            end

            def offset
                self[:offset]
            end
        end

        class MsChmdSecMscompressed < FFI::Struct
            layout({
                :base => MsChmdSection,
                :content => MsChmdFile.ptr,
                :control => MsChmdFile.ptr,
                :rtable => MsChmdFile.ptr,
                :spaninfo => MsChmdFile.ptr
            })

            def base
                self[:base]
            end

            def content
                return nil if self[:content].pointer.address.zero?
                self[:content]
            end

            def control
                return nil if self[:control].pointer.address.zero?
                self[:control]
            end

            def rtable
                return nil if self[:rtable].pointer.address.zero?
                self[:rtable]
            end

            def spaninfo
                return nil if self[:spaninfo].pointer.address.zero?
                self[:spaninfo]
            end
        end

        class MsChmdHeader < FFI::Struct
            layout({
                :version => :uint,
                :timestamp => :uint,
                :language => :uint,
                :filename => :string,
                :length => :off_t,
                :files => MsChmdFile.ptr,
                :sysfiles => MsChmdFile.ptr,
                :sec0 => MsChmdSecUncompressed,
                :sec1 => MsChmdSecMscompressed,
                :dir_offset => :off_t,
                :num_chunks => :uint,
                :chunk_size => :uint,
                :density => :uint,
                :depth => :uint,
                :index_root => :uint,
                :first_pmgl => :uint,
                :last_pmgl => :uint,
                :chunk_cache => :pointer
            })

            def version
                self[:version]
            end

            def timestamp
                self[:timestamp]
            end

            def language
                self[:language]
            end

            def filename
                self[:filename]
            end

            def length
                self[:length]
            end

            def files
                return nil if self[:files].pointer.address.zero?
                self[:files]
            end

            def sysfiles
                return nil if self[:sysfiles].pointer.address.zero?
                self[:sysfiles]
            end

            def sec0
                self[:sec0]
            end

            def sec1
                self[:sec1]
            end

            def dir_offset
                self[:dir_offset]
            end

            def num_chunks
                self[:num_chunks]
            end

            def chunk_size
                self[:chunk_size]
            end

            def density
                self[:density]
            end

            def depth
                self[:depth]
            end

            def index_root
                self[:index_root]
            end

            def first_pmgl
                self[:first_pmgl]
            end

            def last_pmgl
                self[:last_pmgl]
            end

            def chunk_cache
                return nil if self[:chunk_cache].pointer.address.zero?
                self[:chunk_cache]
            end
        end

        class MsChmCompressor < FFI::Struct
            layout({
                :generate => callback([ MsChmCompressor.ptr, MsChmcFile.ptr, :string ], :int),
                :use_temporary_file => callback([ MsChmCompressor.ptr, :int, :string ], :int),
                :set_param => callback([ MsChmCompressor.ptr, :int, :uint ], :int),
                :last_error => callback([ MsChmCompressor.ptr ], :int)
            })

            def generate(compressor, fileList, outputFile)
                self[:generate].call(compressor, fileList, outputFile)
            end

            def use_temporary_file(compressor, useTempFile, tempFile)
                self[:use_temporary_file].call(compressor, useTempFile, tempFile)
            end

            def set_param(compressor, param, value)
                self[:set_param].call(compressor, param, value)
            end

            def last_error(compressor)
                self[:last_error].call(compressor)
            end
        end

        class MsChmDecompressor < FFI::Struct
            layout({
                :open => callback([ MsChmDecompressor.ptr, :string ], MsChmdHeader.ptr),
                :close => callback([ MsChmDecompressor.ptr, MsChmdHeader.ptr ], :void),
                :extract => callback([ MsChmDecompressor.ptr, MsChmdFile.ptr, :string ], :int),
                :last_error => callback([ MsChmDecompressor.ptr ], :int),
                :fast_open => callback([ MsChmDecompressor.ptr, :string ], MsChmdHeader.ptr),
                :fast_find => callback([ MsChmDecompressor.ptr, MsChmdHeader.ptr, :string, MsChmdFile.ptr, :int ], :int)
            })

            def open(decompressor, filename)
                self[:open].call(decompressor, filename)
            end

            def close(decompressor, chm)
                self[:close].call(decompressor, chm)
            end

            def extract(decompressor, file, filename)
                self[:extract].call(decompressor, file, filename)
            end

            def last_error(decompressor)
                self[:last_error].call(decompressor)
            end

            def fast_open(decompressor, filename)
                self[:fast_open].call(decompressor, filename)
            end

            def fast_find(decompressor, chm, filename, file, size)
                self[:fast_find].call(decompressor, chm, filename, file, size)
            end
        end

    end
end
