module LibMsPack
    module Exceptions
        class NotInitializedError < RuntimeError
        end

        class AlreadyInitializedError < RuntimeError
        end

        class LibMsPackError < RuntimeError
        end
    end
end
