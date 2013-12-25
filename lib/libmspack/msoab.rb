module LibMsPack
    module MsOab
        class MsoabCompressor < FFI::Struct
            layout({
                :compress => callback([ :pointer, :string, :string ], :int),
                :compress_incremental => callback([ :pointer, :string, :string, :string ], :int)
            })

            def compress
                self[:compress]
            end

            def compress_incremental
                self[:compress_incremental]
            end

        end

        class MsoabDecompressor < FFI::Struct
            layout({
                :decompress => callback([ :pointer, :string, :string ], :int),
                :decompress_incremental => callback([ :pointer, :string, :string, :string ], :int)
            })

            def decompress
                self[:decompress]
            end

            def decompress_incremental
                self[:decompress_incremental]
            end

        end

    end
end
