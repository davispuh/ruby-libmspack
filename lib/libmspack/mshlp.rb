module LibMsPack
    module MsHlp
        class MsHlpCompressor < FFI::Struct
            layout({
                :dummy => :int
            })
        end

        class MsHlpDecompressor < FFI::Struct
            layout({
                :dummy => :int
            })
        end
    end
end
