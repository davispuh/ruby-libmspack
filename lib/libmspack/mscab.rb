module LibMsPack
    module MsCab
        module Constants
            # Offset from start of cabinet to the reserved header data (if present).
            MSCAB_HDR_RESV_OFFSET = 0x28
            # Cabinet header flag: cabinet has a predecessor.
            MSCAB_HDR_PREVCAB = 0x01
            # Cabinet header flag: cabinet has a successor.
            MSCAB_HDR_NEXTCAB = 0x02
            # Cabinet header flag: cabinet has reserved header space.
            MSCAB_HDR_RESV = 0x04

            # Compression mode: no compression.
            MSCAB_COMP_NONE = 0
            # Compression mode: MSZIP (deflate) compression.
            MSCAB_COMP_MSZIP = 1
            # Compression mode: Quantum compression.
            MSCAB_COMP_QUANTUM = 2
            # Compression mode: LZX compression.
            MSCAB_COMP_LZX = 3

            # attribute: file is read-only.
            MSCAB_ATTRIB_RDONLY = 0x01
            # attribute: file is hidden.
            MSCAB_ATTRIB_HIDDEN = 0x02
            # attribute: file is an operating system file.
            MSCAB_ATTRIB_SYSTEM = 0x04
            # attribute: file is "archived".
            MSCAB_ATTRIB_ARCH = 0x20
            # attribute: file is an executable program.
            MSCAB_ATTRIB_EXEC = 0x40
            # attribute: filename is UTF8, not ISO-8859-1.
            MSCAB_ATTRIB_UTF_NAME = 0x80

            # CabDecompressor#setParam parameter: search buffer size.
            MSCABD_PARAM_SEARCHBUF = 0
            # CabDecompressor#setParam parameter: repair MS-ZIP streams?
            MSCABD_PARAM_FIXMSZIP = 1
            # CabDecompressor#setParam parameter: size of decompression buffer
            MSCABD_PARAM_DECOMPBUF = 2
        end

        # Returns the compression method used by a folder.
        # @param [Fixnum] compType a MsCabdFolder.comp_type value
        # @return [Fixnum] one of MSCAB_COMP_NONE, MSCAB_COMP_MSZIP, MSCAB_COMP_QUANTUM or MSCAB_COMP_LZX
        def self.MsCabdCompMethod(compType)
            compType & 0x0F
        end

        # Returns the compression level used by a folder.
        # @param [Fixnum] compType a MsCabdFolder.comp_type value
        # @return [Fixnum] the compression level. This is only defined by LZX and Quantum compression
        def self.MsCabdCompLevel(compType)
            ((comp_type) >> 8) & 0x1F
        end

        # A structure which represents a single folder in a cabinet or cabinet set.
        #
        # A folder is a single compressed stream of data. When uncompressed, it holds the data of one or more files. A folder may be split across more than one cabinet.
        class MsCabdFolder < FFI::Struct
            layout({
                :next => MsCabdFolder.ptr,
                :comp_type => :int,
                :num_blocks => :uint
            })

            # A next folder in this cabinet or cabinet set, or nil if this is the final folder.
            #
            # @return [MsCabdFolder, nil]
            def next
                return nil if self[:next].pointer.address.zero?
                self[:next]
            end

            # The compression format used by this folder.
            #
            # `#MsCabdCompMethod` should be used on this field to get the algorithm used. `#MsCabdCompLevel` should be used to get the "compression level".
            #
            # @return [Fixnum]
            def comp_type
                self[:comp_type]
            end

            # The total number of data blocks used by this folder.
            #
            # This includes data blocks present in other files, if this folder spans more than one cabinet.
            #
            # @return [Fixnum]
            def num_blocks
                self[:num_blocks]
            end

            # Returns the compression method used by a folder.
            #
            # @return [Fixnum] one of MSCAB_COMP_NONE, MSCAB_COMP_MSZIP, MSCAB_COMP_QUANTUM or MSCAB_COMP_LZX
            def compressionMethod
                MsCab::MsCabdCompMethod(comp_type)
            end

            # Returns the compression level used by a folder.
            #
            # @return [Fixnum] the compression level. This is only defined by LZX and Quantum compression
            def compressionLevel
                MsCab::MsCabdCompLevel(comp_type)
            end
        end

        # A structure which represents a single file in a cabinet or cabinet set.
        class MsCabdFile < FFI::Struct
            layout({
                :next => MsCabdFile.ptr,
                :filename => :string,
                :length => :uint,
                :attribs => :int,
                :time_h => :char,
                :time_m => :char,
                :time_s => :char,
                :date_d => :char,
                :date_m => :char,
                :date_y => :int,
                :folder => MsCabdFolder.ptr,
                :offset => :uint
            })

            # The next file in the cabinet or cabinet set, or nil if this is the final file.
            #
            # @return [MsCabdFile, nil]
            def next
                return nil if self[:next].pointer.address.zero?
                self[:next]
            end

            # The filename of the file.
            #
            # String of up to 255 bytes in length, it may be in either ISO-8859-1 or UTF8 format, depending on the file attributes.
            #
            # @return [String]
            def filename
                self[:filename]
            end

            # The filename of the file.
            #
            # @return [String]
            def getFilename
                str = filename.dup
                if (attribs & Constants::MSCAB_ATTRIB_UTF_NAME) == Constants::MSCAB_ATTRIB_UTF_NAME
                    str.force_encoding(Encoding::UTF_8)
                else
                    str.force_encoding(Encoding::ISO_8859_1)
                end
                str
            end

            # The uncompressed length of the file, in bytes.
            #
            # @return [Fixnum]
            def length
                self[:length]
            end

            # File attributes.
            #
            # The following attributes are defined:
            #
            # * MSCAB_ATTRIB_RDONLY indicates the file is write protected.
            # * MSCAB_ATTRIB_HIDDEN indicates the file is hidden.
            # * MSCAB_ATTRIB_SYSTEM indicates the file is a operating system file.
            # * MSCAB_ATTRIB_ARCH indicates the file is "archived".
            # * MSCAB_ATTRIB_EXEC indicates the file is an executable program.
            # * MSCAB_ATTRIB_UTF_NAME indicates the filename is in UTF8 format rather than ISO-8859-1.
            #
            # @return [Fixnum]
            def attribs
                self[:attribs]
            end

            # File's last modified datetime.
            #
            # @return [Time]
            def datetime
                Time.gm(self[:date_y], self[:date_m], self[:date_d], self[:time_h], self[:time_m], self[:time_s])
            end

            # Folder that contains this file.
            #
            # @return [MsCabdFolder, nil]
            def folder
                return nil if self[:folder].pointer.address.zero?
                self[:folder]
            end

            # The uncompressed offset of this file in its folder.
            #
            # @return [Fixnum]
            def offset
                self[:offset]
            end
        end

        # A structure which represents a single cabinet file.
        #
        # If this cabinet is part of a merged cabinet set, the files and folders fields are common to all cabinets in the set, and will be identical.
        class MsCabdCabinet < FFI::Struct
            layout({
                :next => MsCabdCabinet.ptr,
                :filename => :string,
                :base_offset => :off_t,
                :length => :uint,
                :prevcab => MsCabdCabinet.ptr,
                :nextcab => MsCabdCabinet.ptr,
                :prevname => :string,
                :nextname => :string,
                :previnfo => :string,
                :nextinfo => :string,
                :files => MsCabdFile.ptr,
                :folders => MsCabdFolder.ptr,
                :set_id => :ushort,
                :set_index => :ushort,
                :header_resv => :ushort,
                :flags => :int
            })

            # The next cabinet in a chained list, if this cabinet was opened with MsCabDecompressor#search
            #
            # May be nil to mark the end of the list.
            #
            # @return [MsCabdCabinet, nil]
            def next
                return nil if self[:next].pointer.address.zero?
                self[:next]
            end

            # The filename of the cabinet.
            #
            # More correctly, the filename of the physical file that the cabinet resides in. This is given by the library user and may be in any format.
            #
            # @return [String]
            def filename
                self[:filename]
            end

            # The file offset of cabinet within the physical file it resides in.
            #
            # @return [Fixnum]
            def base_offset
                self[:base_offset]
            end

            # The length of the cabinet file in bytes.
            #
            # @return [Fixnum]
            def length
                self[:length]
            end

            # The previous cabinet in a cabinet set, or nil.
            #
            # @return [MsCabdCabinet, nil]
            def prevcab
                return nil if self[:prevcab].pointer.address.zero?
                self[:prevcab]
            end

            # The next cabinet in a cabinet set, or nil.
            #
            # @return [MsCabdCabinet, nil]
            def nextcab
                return nil if self[:nextcab].pointer.address.zero?
                self[:nextcab]
            end

            # The filename of the previous cabinet in a cabinet set, or nil.
            #
            # @return [String]
            def prevname
                self[:prevname]
            end

            # The filename of the next cabinet in a cabinet set, or nil.
            #
            # @return [String]
            def nextname
                self[:nextname]
            end

            # The name of the disk containing the previous cabinet in a cabinet set, or nil.
            #
            # @return [String]
            def previnfo
                self[:previnfo]
            end

            # The name of the disk containing the next cabinet in a cabinet set, or nil.
            #
            # @return [String]
            def nextinfo
                self[:nextinfo]
            end

            # A list of all files in the cabinet or cabinet set.
            #
            # @return [MsCabdFile, nil]
            def files
                return nil if self[:files].pointer.address.zero?
                self[:files]
            end

            # A list of all folders in the cabinet or cabinet set.
            #
            # @return [MsCabdFolder, nil]
            def folders
                return nil if self[:folders].pointer.address.zero?
                self[:folders]
            end

            # The set ID of the cabinet.
            #
            # All cabinets in the same set should have the same set ID.
            #
            # @return [Fixnum]
            def set_id
                self[:set_id]
            end

            # The index number of the cabinet within the set.
            #
            # Numbering should start from 0 for the first cabinet in the set, and increment by 1 for each following cabinet.
            #
            # @return [Fixnum]
            def set_index
                self[:set_index]
            end

            # The number of bytes reserved in the header area of the cabinet.
            #
            # If this is non-zero and flags has MSCAB_HDR_RESV set, this data can be read by the calling application. It is of the given length, located at offset (base_offset + MSCAB_HDR_RESV_OFFSET) in the cabinet file.
            #
            # @see #flags flags
            # @return [Fixnum]
            def header_resv
                self[:header_resv]
            end

            # Header flags.
            #
            # * MSCAB_HDR_PREVCAB indicates the cabinet is part of a cabinet set, and has a predecessor cabinet.
            # * MSCAB_HDR_NEXTCAB indicates the cabinet is part of a cabinet set, and has a successor cabinet.
            # * MSCAB_HDR_RESV indicates the cabinet has reserved header space.
            #
            # @see #prevname prevname
            # @see #previnfo previnfo
            # @see #nextname nextname
            # @see #nextinfo nextinfo
            # @see #header_resv header_resv
            # @return [Fixnum]
            def flags
                self[:flags]
            end
        end

        # CAB compressor
        class MsCabCompressor < FFI::Struct
            layout({:dummy => :int})
        end

        # CAB decompressor
        class MsCabDecompressor < FFI::Struct
            layout({
                :open => callback([ MsCabDecompressor.ptr, :string ], MsCabdCabinet.ptr),
                :close => callback([ MsCabDecompressor.ptr, MsCabdCabinet.ptr ], :void),
                :search => callback([ MsCabDecompressor.ptr, :string ], MsCabdCabinet.ptr),
                :append => callback([ MsCabDecompressor.ptr, MsCabdCabinet.ptr, MsCabdCabinet.ptr ], :int),
                :prepend => callback([ MsCabDecompressor.ptr, MsCabdCabinet.ptr, MsCabdCabinet.ptr ], :int),
                :extract => callback([ MsCabDecompressor.ptr, MsCabdFile.ptr, :string ], :int),
                :set_param => callback([ MsCabDecompressor.ptr, :int, :int ], :int),
                :last_error => callback([ MsCabDecompressor.ptr ], :int)
            })

            # Opens a cabinet file and reads its contents.
            #
            # If the file opened is a valid cabinet file, all headers will be read and a MsCabdCabinet structure will be returned, with a full list of folders and files.
            #
            # In the case of an error occuring, nil is returned and the error code is available from #last_error
            #
            # @param [MsCabDecompressor] decompressor MsCabDecompressor instance being called
            # @param [String] filename name of the cabinet file
            # @return [MsCabdCabinet, nil]
            # @see #close close
            # @see #search search
            # @see #last_error last_error
            def open(decompressor, filename)
                self[:open].call(decompressor, filename)
            end

            # Closes a previously opened cabinet or cabinet set.
            #
            # This closes a cabinet, all cabinets associated with it via the MsCabdCabinet#next, MsCabdCabinet#prevcab and MsCabdCabinet#nextcab, and all folders and files. All memory used by these entities is freed.
            #
            # The cabinet is now invalid and cannot be used again. All MsCabdFolder and MsCabdFile from that cabinet or cabinet set are also now invalid, and cannot be used again.
            #
            # If the cabinet given was created using #search, it MUST be the cabinet returned by #search and not one of the later cabinet pointers further along the MsCabdCabinet::next chain.
            #
            # If extra cabinets have been added using #append or #prepend, these will all be freed, even if the cabinet given is not the first cabinet in the set. Do NOT #close more than one cabinet in the set.
            #
            # @param [MsCabDecompressor] decompressor MsCabDecompressor instance being called
            # @param [MsCabdCabinet] cabinet the cabinet to close
            # @see #open open
            # @see #search search
            # @see #append append
            # @see #prepend prepend
            def close(decompressor, cabinet)
                self[:close].call(decompressor, cabinet)
            end

            # Searches a regular file for embedded cabinets.
            #
            # This opens a normal file with the given filename and will search the entire file for embedded cabinet files
            #
            # If any cabinets are found, the equivalent of #open is called on each potential cabinet file at the offset it was found. All successfully #open'ed cabinets are kept in a list.
            #
            # The first cabinet found will be returned directly as the result of this method. Any further cabinets found will be chained in a list using the MsCabdCabinet#next field.
            #
            # In the case of an error occuring anywhere other than the simulated #open, nil is returned and the error code is available from #last_error
            #
            # If no error occurs, but no cabinets can be found in the file, nil is returned and #last_error returns MSPACK_ERR_OK
            #
            # `#close` should only be called on the result of #search, not on any subsequent cabinets in the MsCabdCabinet#next chain.
            #
            # @param [MsCabDecompressor] decompressor MsCabDecompressor instance being called
            # @param [String] filename the filename of the file to search for cabinets
            # @return [MsCabdCabinet, nil]
            # @see #close close
            # @see #open open
            # @see #last_error last_error
            def search(decompressor, filename)
                self[:search].call(decompressor, filename)
            end

            # Appends one MsCabdCabinet to another, forming or extending a cabinet set.
            #
            # This will attempt to append one cabinet to another such that (cab.nextcab == nextcab) && (nextcab.prevcab == cab) and any folders split between the two cabinets are merged.
            #
            # The cabinets MUST be part of a cabinet set -- a cabinet set is a cabinet that spans more than one physical cabinet file on disk -- and must be appropriately matched.
            #
            # It can be determined if a cabinet has further parts to load by examining the MsCabdCabinet.flags field:
            #
            # * if (flags & MSCAB_HDR_PREVCAB) is non-zero, there is a predecessor cabinet to #open and #prepend. Its MS-DOS case-insensitive filename is MsCabdCabinet.prevname
            # * if (flags & MSCAB_HDR_NEXTCAB) is non-zero, there is a successor cabinet to #open and #append. Its MS-DOS case-insensitive filename is MsCabdCabinet.nextname
            #
            # If the cabinets do not match, an error code will be returned. Neither cabinet has been altered, and both should be closed seperately.
            #
            # Files and folders in a cabinet set are a single entity. All cabinets in a set use the same file list, which is updated as cabinets in the set are added.
            #
            # @param [MsCabDecompressor] decompressor MsCabDecompressor instance being called
            # @param [MsCabdCabinet] cab the cabinet which will be appended to, predecessor of nextcab
            # @param [MsCabdCabinet] nextcab the cabinet which will be appended, successor of cab
            # @return [Fixnum] an error code, or MSPACK_ERR_OK if successful
            # @see #prepend prepend
            # @see #open open
            # @see #close close
            def append(decompressor, cab, nextcab)
                self[:append].call(decompressor, cab, nextcab)
            end

            # Prepends one MsCabdCabinet to another, forming or extending a cabinet set.
            #
            # This will attempt to prepend one cabinet to another, such that (cab.prevcab == prevcab) && (prevcab.nextcab == cab).
            # In all other respects, it is identical to #append.
            #
            # @see #append #append for the full documentation
            # @param [MsCabDecompressor] decompressor MsCabDecompressor instance being called
            # @param [MsCabdCabinet] cab the cabinet which will be prepended to, successor of prevcab
            # @param [MsCabdCabinet] prevcab the cabinet which will be prepended, predecessor of cab
            # @see #append append
            # @see #open open
            # @see #close close
            def prepend(decompressor, cab, prevcab)
                self[:prepend].call(decompressor, cab, prevcab)
            end

            # Extracts a file from a cabinet or cabinet set.
            #
            # This extracts a compressed file in a cabinet and writes it to the given filename.
            #
            # The MS-DOS filename of the file, MsCabdCabinet.filename, is NOT USED by #extract. The caller must examine this MS-DOS filename, copy and change it as necessary, create directories as necessary, and provide the correct filename as a parameter, which will be passed unchanged to the decompressor's MsPackSystem#open
            #
            # If the file belongs to a split folder in a multi-part cabinet set, and not enough parts of the cabinet set have been loaded and appended or prepended, an error will be returned immediately.
            #
            # @param [MsCabDecompressor] decompressor MsCabDecompressor instance being called
            # @param [MsCabdFile] cabfile the file to be decompressed
            # @param [String] filename the filename of the file being written to
            # @return [Fixnum] an error code, or MSPACK_ERR_OK if successful
            def extract(decompressor, cabfile, filename)
                self[:extract].call(decompressor, cabfile, filename)
            end

            # Sets a CAB decompression engine parameter.
            #
            # The following parameters are defined:
            #
            # * MSCABD_PARAM_SEARCHBUF: How many bytes should be allocated as a buffer when using #search ? The minimum value is 4. The default value is 32768.
            # * MSCABD_PARAM_FIXMSZIP: If non-zero, #extract will ignore bad checksums and recover from decompression errors in MS-ZIP compressed folders. The default value is 0 (don't recover).
            # * MSCABD_PARAM_DECOMPBUF: How many bytes should be used as an input bit buffer by decompressors? The minimum value is 4. The default value is 4096.
            #
            # @param [MsCabDecompressor] decompressor MsCabDecompressor instance being called
            # @param [Fixnum] param the parameter to set
            # @param [Fixnum] value the value to set the parameter to
            # @see #close close
            # @see #open open
            def set_param(decompressor, param, value)
                self[:set_param].call(decompressor, param, value)
            end

            # Returns the error code set by the most recently called method
            # @param [MsCabDecompressor] decompressor MsCabDecompressor instance being called
            # @return [Fixnum] the most recent error code
            # @see #open open
            # @see #search search
            def last_error(decompressor)
                self[:last_error].call(decompressor)
            end

        end

        # CAB Compressor
        class CabCompressor
            attr_reader :Compressor
            # Creates a new CAB compressor.
            #
            # @param [MsPack::MsPackSystem, nil] system is a custom mspack system, or nil to use the default
            def initialize(system = nil)
                @Compressor = nil
                init(system)
            end

            # @private
            def init(system = MsPack::RubyPackSystem)
                raise Exceptions::AlreadyInitializedError if @Compressor
                @Compressor = LibMsPack.CreateCabCompressor(system)
            end

            # Destroys an existing CAB compressor
            def destroy
                raise Exceptions::NotInitializedError unless @Compressor
                LibMsPack.DestroyCabCompressor(@Compressor)
                @Compressor = nil
            end
        end

        # CAB decompressor
        class CabDecompressor
            attr_reader :Decompressor
            # Creates a new CAB decompressor.
            #
            # @param [MsPack::MsPackSystem, nil] system a custom mspack system, or nil to use the default
            def initialize(system = nil)
                @Decompressor = nil
                init(system)
            end

            # @private
            def init(system = MsPack::RubyPackSystem)
                raise Exceptions::AlreadyInitializedError if @Decompressor
                @Decompressor = LibMsPack.CreateCabDecompressor(system)
            end

            # Opens a cabinet file and reads its contents.
            #
            # If the file opened is a valid cabinet file, all headers will be read and a MsCabdCabinet structure will be returned, with a full list of folders and files.
            #
            # In the case of an error occuring, exception will be raised.
            #
            # @param [String] filename name of the cabinet file
            # @return [MsCabdCabinet]
            # @raise [Exceptions::LibMsPackError]
            # @see #close close
            # @see #search search
            def open(filename)
                raise Exceptions::NotInitializedError unless @Decompressor
                cabinet = @Decompressor.open(@Decompressor, filename)
                error = lastError
                raise Exceptions::LibMsPackError.new(error) unless error == LibMsPack::MSPACK_ERR_OK
                cabinet
            end

            # Closes a previously opened cabinet or cabinet set.
            #
            # This closes a cabinet, all cabinets associated with it via the MsCabdCabinet#next, MsCabdCabinet#prevcab and MsCabdCabinet#nextcab, and all folders and files. All memory used by these entities is freed.
            #
            # The cabinet is now invalid and cannot be used again. All MsCabdFolder and MsCabdFile from that cabinet or cabinet set are also now invalid, and cannot be used again.
            #
            # If the cabinet given was created using #search, it MUST be the cabinet returned by #search and not one of the later cabinet pointers further along the MsCabdCabinet::next chain.
            #
            # If extra cabinets have been added using #append or #prepend, these will all be freed, even if the cabinet given is not the first cabinet in the set. Do NOT #close more than one cabinet in the set.
            #
            # @param [MsCabdCabinet] cabinet the cabinet to close
            # @see #open open
            # @see #search search
            # @see #append append
            # @see #prepend prepend
            def close(cabinet)
                raise Exceptions::NotInitializedError unless @Decompressor
                @Decompressor.close(@Decompressor, cabinet)
            end

            # Searches a regular file for embedded cabinets.
            #
            # This opens a normal file with the given filename and will search the entire file for embedded cabinet files
            #
            # If any cabinets are found, the equivalent of #open is called on each potential cabinet file at the offset it was found. All successfully #open'ed cabinets are kept in a list.
            #
            # The first cabinet found will be returned directly as the result of this method. Any further cabinets found will be chained in a list using the MsCabdCabinet#next field.
            #
            # In the case of an error occuring anywhere other than the simulated #open, exception will be raised.
            #
            # If no error occurs, but no cabinets can be found in the file, nil is returned.
            #
            # `#close` should only be called on the result of #search, not on any subsequent cabinets in the MsCabdCabinet#next chain.
            #
            # @param [String] filename the filename of the file to search for cabinets
            # @return [MsCabdCabinet]
            # @raise [Exceptions::LibMsPackError]
            # @see #close close
            # @see #open open
            def search(filename)
                raise Exceptions::NotInitializedError unless @Decompressor
                cabinet = @Decompressor.search(@Decompressor, filename)
                error = lastError
                raise Exceptions::LibMsPackError.new(error) unless error == LibMsPack::MSPACK_ERR_OK
                cabinet
            end

            # Appends one MsCabdCabinet to another, forming or extending a cabinet set.
            #
            # This will attempt to append one cabinet to another such that (cab.nextcab == nextcab) && (nextcab.prevcab == cab) and any folders split between the two cabinets are merged.
            #
            # The cabinets MUST be part of a cabinet set -- a cabinet set is a cabinet that spans more than one physical cabinet file on disk -- and must be appropriately matched.
            #
            # It can be determined if a cabinet has further parts to load by examining the MsCabdCabinet.flags field:
            #
            # * if (flags & MSCAB_HDR_PREVCAB) is non-zero, there is a predecessor cabinet to #open and #prepend. Its MS-DOS case-insensitive filename is MsCabdCabinet.prevname
            # * if (flags & MSCAB_HDR_NEXTCAB) is non-zero, there is a successor cabinet to #open and #append. Its MS-DOS case-insensitive filename is MsCabdCabinet.nextname
            #
            # If the cabinets do not match, an exception will be raised. Neither cabinet has been altered, and both should be closed seperately.
            #
            # Files and folders in a cabinet set are a single entity. All cabinets in a set use the same file list, which is updated as cabinets in the set are added.
            #
            # @param [MsCabdCabinet] cab the cabinet which will be appended to, predecessor of nextcab
            # @param [MsCabdCabinet] nextcab the cabinet which will be appended, successor of cab
            # @raise [Exceptions::LibMsPackError]
            # @see #prepend prepend
            # @see #open open
            # @see #close close
            def append(cab, nextcab)
                raise Exceptions::NotInitializedError unless @Decompressor
                error = @Decompressor.append(@Decompressor, cab, nextcab)
                raise Exceptions::LibMsPackError.new(error) unless error == LibMsPack::MSPACK_ERR_OK
                error
            end

            # Prepends one MsCabdCabinet to another, forming or extending a cabinet set.
            #
            # This will attempt to prepend one cabinet to another, such that (cab.prevcab == prevcab) && (prevcab.nextcab == cab).
            # In all other respects, it is identical to #append.
            #
            # @see #append #append for the full documentation
            # @param [MsCabdCabinet] cab the cabinet which will be prepended to, successor of prevcab
            # @param [MsCabdCabinet] prevcab the cabinet which will be prepended, predecessor of cab
            # @raise [Exceptions::LibMsPackError]
            # @see #append append
            # @see #open open
            # @see #close close
            def prepend(cab, prevcab)
                raise Exceptions::NotInitializedError unless @Decompressor
                error = @Decompressor.prepend(@Decompressor, cab, prevcab)
                raise Exceptions::LibMsPackError.new(error) unless error == LibMsPack::MSPACK_ERR_OK
                error
            end

            # Extracts a file from a cabinet or cabinet set.
            #
            # This extracts a compressed file in a cabinet and writes it to the given filename.
            #
            # The MS-DOS filename of the file, MsCabdCabinet.filename, is NOT USED by #extract. The caller must examine this MS-DOS filename, copy and change it as necessary, create directories as necessary, and provide the correct filename as a parameter, which will be passed unchanged to the decompressor's MsPackSystem#open
            #
            # If the file belongs to a split folder in a multi-part cabinet set, and not enough parts of the cabinet set have been loaded and appended or prepended, an exception will be raised immediately.
            #
            # @param [MsCabdFile] cabfile the file to be decompressed
            # @param [String] filename the filename of the file being written to
            # @raise [Exceptions::LibMsPackError]
            def extract(cabfile, filename)
                raise Exceptions::NotInitializedError unless @Decompressor
                error = @Decompressor.extract(@Decompressor, cabfile, filename)
                raise Exceptions::LibMsPackError.new(error) unless error == LibMsPack::MSPACK_ERR_OK
                error
            end

            # Sets a CAB decompression engine parameter.
            #
            # The following parameters are defined:
            #
            # * MSCABD_PARAM_SEARCHBUF: How many bytes should be allocated as a buffer when using #search ? The minimum value is 4. The default value is 32768.
            # * MSCABD_PARAM_FIXMSZIP: If non-zero, #extract will ignore bad checksums and recover from decompression errors in MS-ZIP compressed folders. The default value is 0 (don't recover).
            # * MSCABD_PARAM_DECOMPBUF: How many bytes should be used as an input bit buffer by decompressors? The minimum value is 4. The default value is 4096.
            #
            # @param [Fixnum] param the parameter to set
            # @param [Fixnum] value the value to set the parameter to
            # @raise [Exceptions::LibMsPackError]
            # @see #close close
            # @see #open open
            def setParam(param, value)
                raise Exceptions::NotInitializedError unless @Decompressor
                error = @Decompressor.set_param(@Decompressor, param, value)
                raise Exceptions::LibMsPackError.new(error) unless error == LibMsPack::MSPACK_ERR_OK
                error
            end

            # Returns the error code set by the most recently called method
            # @return [Fixnum] the most recent error code
            def lastError
                raise Exceptions::NotInitializedError unless @Decompressor
                @Decompressor.last_error(@Decompressor)
            end

            # Destroys an existing CAB decompressor
            def destroy
                raise Exceptions::NotInitializedError unless @Decompressor
                LibMsPack.DestroyCabDecompressor(@Decompressor)
                @Decompressor = nil
            end
        end

    end
end
