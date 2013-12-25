module LibMsPack
    module MsLit
        module Constants
        end

        class MsLitCompressor < FFI::Struct
            layout({
                :dummy => :int
            })
        end

        class MsLitDecompressor < FFI::Struct
            layout({
                :dummy => :int
            })
        end
    end
end
