module LibMsPack
    module MsSzdd
        module Constants
            MSSZDDC_PARAM_MISSINGCHAR = 0
            MSSZDD_FMT_NORMAL = 0
            MSSZDD_FMT_QBASIC = 1
        end

        class MsSzdddHeader < FFI::Struct
            layout({
                :format => :int,
                :length => :off_t,
                :missing_char => :char
            })

            def format
                self[:format]
            end

            def length
                self[:length]
            end

            def missing_char
                self[:missing_char]
            end
        end

        class MsSzddCompressor < FFI::Struct
            layout({
                :compress => callback([ :pointer, :string, :string, :off_t ], :int),
                :set_param => callback([ :pointer, :int, :uint ], :int),
                :last_error => callback([ :pointer ], :int)
            })

            def compress
                self[:compress]
            end

            def set_param
                self[:set_param]
            end

            def last_error
                self[:last_error]
            end

        end

        class MsSzddDecompressor < FFI::Struct
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
