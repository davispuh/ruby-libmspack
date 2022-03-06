require 'ffi'
require 'ffi-compiler/loader'
require 'libmspack/version'
require 'libmspack/exceptions'
require 'libmspack/mspack'
require 'libmspack/system'
require 'libmspack/mscab'
require 'libmspack/mschm'
require 'libmspack/mshlp'
require 'libmspack/mskwaj'
require 'libmspack/mslit'
require 'libmspack/msoab'
require 'libmspack/msszdd'
require 'libmspack/constants'

module LibMsPack
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('mspack')

    include LibMsPack::Constants
    include LibMsPack::MsPack
    include LibMsPack::MsCab
    include LibMsPack::MsChm
    include LibMsPack::MsHlp
    include LibMsPack::MsKwaj
    include LibMsPack::MsLit
    include LibMsPack::MsOab
    include LibMsPack::MsSzdd

    attach_function :SysSelfTestInternal, :mspack_sys_selftest_internal, [ :int ], :int

    # Enquire about the binary compatibility version of a specific interface in the library.
    #
    # Currently, the following interfaces are defined:
    #
    # * MSPACK_VER_LIBRARY: the overall library
    # * MSPACK_VER_SYSTEM: the MsPackSystem interface
    # * MSPACK_VER_MSCABD: the MsCabDecompressor interface
    # * MSPACK_VER_MSCABC: the MsCabCompressor interface
    # * MSPACK_VER_MSCHMD: the MsChmDecompressor interface
    # * MSPACK_VER_MSCHMC: the MsChmCompressor interface
    # * MSPACK_VER_MSLITD: the MsLitDecompressor interface
    # * MSPACK_VER_MSLITC: the MsLitCompressor interface
    # * MSPACK_VER_MSHLPD: the MsHlpDecompressor interface
    # * MSPACK_VER_MSHLPC: the MsHlpCompressor interface
    # * MSPACK_VER_MSSZDDD: the MsSzddDecompressor interface
    # * MSPACK_VER_MSSZDDC: the MsSzddCompressor interface
    # * MSPACK_VER_MSKWAJD: the MsKwajDecompressor interface
    # * MSPACK_VER_MSKWAJC: the MsKwajCompressor interface
    # * MSPACK_VER_MSOABD: the MsOabDecompressor interface
    # * MSPACK_VER_MSOABC: the MsOabCompressor interface
    #
    # The result of the function should be interpreted as follows:
    #
    # * -1: this interface is completely unknown to the library
    # *  0: this interface is known, but non-functioning
    # *  1: this interface has all basic functionality
    # *  2, 3, ...: this interface has additional functionality, clearly marked in the documentation as "version 2", "version 3" and so on.
    #
    # @!method Version(entity)
    # @param [Fixnum] entity the interface to request current version of
    # @return [Fixnum] the version of the requested interface
    attach_function :Version, :mspack_version, [ :int ], :int

    # Creates a new CAB compressor.
    # @!method CreateCabCompressor(sys)
    # @param [MsPack::MsPackSystem, nil] sys a custom mspack system, or nil to use the default
    # @return [MsCab::MsCabCompressor, nil]
    attach_function :CreateCabCompressor, :mspack_create_cab_compressor, [ MsPackSystem.ptr ], MsCabCompressor.ptr

    # Destroys an existing CAB compressor.
    # @!method DestroyCabCompressor(system)
    # @param [MsCab::MsCabCompressor] compressor the MsCab::MsCabCompressor to destroy
    attach_function :DestroyCabCompressor, :mspack_destroy_cab_compressor, [ MsCabCompressor.ptr ], :void

    # Creates a new CAB decompressor.
    # @!method CreateCabDecompressor(sys)
    # @param [MsPack::MsPackSystem, nil] sys a custom mspack system, or nil to use the default
    # @return [MsCab::MsCabDecompressor, nil]
    attach_function :CreateCabDecompressor, :mspack_create_cab_decompressor, [ MsPackSystem.ptr ], MsCabDecompressor.ptr

    # Destroys an existing CAB decompressor.
    # @!method DestroyCabDecompressor(decompressor)
    # @param [MsCab::MsCabDecompressor] decompressor the MsCab::MsCabDecompressor to destroy
    attach_function :DestroyCabDecompressor, :mspack_destroy_cab_decompressor, [ MsCabDecompressor.ptr ], :void

    attach_function :CreateChmCompressor, :mspack_create_chm_compressor, [ MsPackSystem.ptr ], :pointer
    attach_function :DestroyChmCompressor, :mspack_destroy_chm_compressor, [ :pointer ], :void
    attach_function :CreateChmDecompressor, :mspack_create_chm_decompressor, [ MsPackSystem.ptr ], :pointer
    attach_function :DestroyChmDecompressor, :mspack_destroy_chm_decompressor, [ :pointer ], :void
    attach_function :CreateLitCompressor, :mspack_create_lit_compressor, [ MsPackSystem.ptr ], MsLitCompressor.ptr
    attach_function :DestroyLitCompressor, :mspack_destroy_lit_compressor, [ MsLitCompressor.ptr ], :void
    attach_function :CreateLitDecompressor, :mspack_create_lit_decompressor, [ MsPackSystem.ptr ], MsLitDecompressor.ptr
    attach_function :DestroyLitDecompressor, :mspack_destroy_lit_decompressor, [ MsLitDecompressor.ptr ], :void
    attach_function :CreateHlpCompressor, :mspack_create_hlp_compressor, [ MsPackSystem.ptr ], MsHlpCompressor.ptr
    attach_function :DestroyHlpCompressor, :mspack_destroy_hlp_compressor, [ MsHlpCompressor.ptr ], :void
    attach_function :CreateHlpDecompressor, :mspack_create_hlp_decompressor, [ MsPackSystem.ptr ], MsHlpDecompressor.ptr
    attach_function :DestroyHlpDecompressor, :mspack_destroy_hlp_decompressor, [ MsHlpDecompressor.ptr ], :void
    attach_function :CreateSzddCompressor, :mspack_create_szdd_compressor, [ MsPackSystem.ptr ], :pointer
    attach_function :DestroySzddCompressor, :mspack_destroy_szdd_compressor, [ :pointer ], :void
    attach_function :CreateSzddDecompressor, :mspack_create_szdd_decompressor, [ MsPackSystem.ptr ], :pointer
    attach_function :DestroySzddDecompressor, :mspack_destroy_szdd_decompressor, [ :pointer ], :void
    attach_function :CreateKwajCompressor, :mspack_create_kwaj_compressor, [ MsPackSystem.ptr ], :pointer
    attach_function :DestroyKwajCompressor, :mspack_destroy_kwaj_compressor, [ :pointer ], :void
    attach_function :CreateKwajDecompressor, :mspack_create_kwaj_decompressor, [ MsPackSystem.ptr ], :pointer
    attach_function :DestroyKwajDecompressor, :mspack_destroy_kwaj_decompressor, [ :pointer ], :void
    attach_function :CreateOabCompressor, :mspack_create_oab_compressor, [ MsPackSystem.ptr ], :pointer
    attach_function :DestroyOabCompressor, :mspack_destroy_oab_compressor, [ :pointer ], :void
    attach_function :CreateOabDecompressor, :mspack_create_oab_decompressor, [ MsPackSystem.ptr ], :pointer
    attach_function :DestroyOabDecompressor, :mspack_destroy_oab_decompressor, [ :pointer ], :void

    # System self-test function, to ensure both library and calling program can use one another.
    #
    # A result of MSPACK_ERR_OK means the library and caller are compatible. Any other result indicates that the library and caller are not compatible and should not be used. In particular, a value of MSPACK_ERR_SEEK means the library and caller use different off_t datatypes.
    #
    # @return [Fixnum] the result of the self-test
    def self.SysSelfTest
        LibMsPack.SysSelfTestInternal(8)
    end

end
