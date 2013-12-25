module LibMsPack
    module MsKwaj
        module Constants

            MSKWAJC_PARAM_COMP_TYPE = 0
            MSKWAJC_PARAM_INCLUDE_LENGTH = 1

            MSKWAJ_COMP_NONE = 0
            MSKWAJ_COMP_XOR = 1
            MSKWAJ_COMP_SZDD = 2
            MSKWAJ_COMP_LZH = 3
            MSKWAJ_COMP_MSZIP = 4

            MSKWAJ_HDR_HASLENGTH = 0x01
            MSKWAJ_HDR_HASUNKNOWN1 = 0x02
            MSKWAJ_HDR_HASUNKNOWN2 = 0x04
            MSKWAJ_HDR_HASFILENAME = 0x08
            MSKWAJ_HDR_HASFILEEXT = 0x10
            MSKWAJ_HDR_HASEXTRATEXT = 0x20

        end

        class MsKwajdHeader < FFI::Struct
            layout({
                :comp_type => :ushort,
                :data_offset => :off_t,
                :headers => :int,
                :length => :off_t,
                :filename => :string,
                :extra => :pointer,
                :extra_length => :ushort
            })

            def comp_type
                self[:comp_type]
            end

            def data_offset
                self[:data_offset]
            end

            def headers
                self[:headers]
            end

            def length
                self[:length]
            end

            def filename
                self[:filename]
            end

            def extra
                self[:extra]
            end

            def extra_length
                self[:extra_length]
            end
        end

        class MsKwajCompressor < FFI::Struct
            layout({
                :compress => callback([ :pointer, :string, :string, :off_t ], :int),
                :set_param => callback([ :pointer, :int, :uint ], :int),
                :set_filename => callback([ :pointer, :string ], :int),
                :set_extra_data => callback([ :pointer, :pointer, :uint ], :int),
                :last_error => callback([ :pointer ], :int)
            })

            def compress
                self[:compress]
            end

            def set_param
                self[:set_param]
            end

            def set_filename
                self[:set_filename]
            end

            def set_extra_data
                self[:set_extra_data]
            end

            def last_error
                self[:last_error]
            end
        end

        class MsKwajDecompressor < FFI::Struct
            layout({
                :open => callback([ :pointer, :string ], :pointer),
                :close => callback([ :pointer, :pointer ], :void),
                :extract => callback([ :pointer, :pointer, :string ], :int),
                :decompress => callback([ :pointer, :string, :string ], :int),
                :last_error => callback([ :pointer ], :int)
            })

            def open
                self[:open]
            end

            def close
                self[:close]
            end

            def extract
                self[:extract]
            end

            def decompress
                self[:decompress]
            end

            def last_error
                self[:last_error]
            end
        end

    end
end
