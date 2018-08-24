require "gzip"

# Library for parsing MacOS FSEvents files found in /.fseventsd/
module FSE

  PAGE_HEADER_SIZE = 12
  STATUS_ABORT = -2

  class ParserListener

    def on_file(filename : String)
      @filename = filename
    end

    def on_page(version : Int32, page_size : UInt32)
    end

    # if bytes_processed < page_size, the file was incomplete, or other error
    def on_page_end(readlen : Int32|UInt32, page_size : UInt32, errmsg : String)
    end

    def on_record(record_id : UInt64, flags : UInt32, path : String, node_id : String, record_end_offset : String)
      return STATUS_ABORT
    end
  end


  class Parser

    def initialize()
      @io = IO::Memory.new
      @haveSig = false
      @version = 0_u32
      @verbose = false
    end

    #----------------------------------------------------------------------
    # opens and processes file 'filename', and notifies 'listener' for
    # each record
    #----------------------------------------------------------------------
    def read(filename : String, listener : ParserListener)
      listener.on_file filename

      File.open(filename) do |file|
        file_magic = Bytes.new(3)
        file.read(file_magic)
        file.rewind
        if file_magic.hexstring == "1f8b08"
          Gzip::Reader.open(file) do |zio|
            process_file zio, listener
          end # gzip
        else
          # uncompressed
          process_file file, listener
        end
      end # while remaining

    end

    def test_process_file(io, listener)
      process_file io, listener
    end

    #----------------------------------------------------------------------
    # process_file
    #----------------------------------------------------------------------
    private def process_file(zio, listener)
      bytes = Bytes.new(32*1024)
      page_version = 0_u32
      page_size = 0_u32

      loop do
        readlen = zio.read(bytes)
        if readlen == 0
          if @io.size > PAGE_HEADER_SIZE
            # parse page even if it's not complete
            #if @verbose { puts "Parsing incomplete page" }
            @io.rewind
            page_version, page_size = read_page_header @io
            read_records @io, page_version, page_size, listener
          end
          break
        end

        # append to io

        @io.write(bytes[0, readlen])

        #puts "read #{readlen} io.size:#{@io.size}"

        if page_size == 0
          next if @io.size < PAGE_HEADER_SIZE

          @io.rewind
          page_version, page_size = read_page_header @io
          @io.pos = @io.size
        end

        next if @io.size < (page_size + PAGE_HEADER_SIZE)

        # we have entire page in @io, process records

        @io.pos = PAGE_HEADER_SIZE
        read_records @io, page_version, page_size, listener

        # compact @io buffer

        if @io.pos != @io.size
          tmp = @io
          @io = IO::Memory.new
          #puts "Compact pos:#{tmp.pos} size:#{tmp.size}"
          @io.write tmp.to_slice[tmp.pos, tmp.size-tmp.pos]
          #puts "  after io.pos:#{@io.pos} size:#{@io.size}"
          tmp.clear
        else
          @io.clear
        end

        # reset page details

        page_size = 0_u32
        page_version = 0
      end # loop
    end

    #----------------------------------------------------------------------
    # reads the page header
    # offset  length  field       notes
    # 0       4       magic       Either '1DLS' or '2DLS'
    # 4       4       uknown
    # 8       4       page_size   Includes header bytes
    #
    # @returns array [ page_version, page_size ]
    # where page_version is integer 1 or 2 depending on magic / sig
    #----------------------------------------------------------------------
    private def read_page_header(io)
      sig = io.read_bytes UInt32
      unk = io.read_bytes UInt32
      page_size = io.read_bytes UInt32

      # sanity check magic, masking off the version byte

      if sig & 0xFFFFFF00_u32 != 0x444c5300
        # no valid page header.
        STDERR.puts "Missing valid page header"
        return [0,page_size]
        break
      end

      # calc version and return

      page_version = (sig & 0x0FF) - '0'.ord
      return [page_version, page_size]
    end

    #----------------------------------------------------------------------
    # reads all records for a page
    #----------------------------------------------------------------------
    private def read_records(io, version, page_size, listener)

      errmsg = ""
      bytes = io.to_slice
      end_of_page = page_size #io.pos + page_size

      #if @verbose { puts "read_records offset:#{io.pos} size:#{io.size} page_size:#{page_size}" }

      i = 0
      while io.pos < end_of_page
        begin

          # path string is first - have to find null ( 0 ) character

          start = io.pos
          pos = io.pos
          while pos < end_of_page && bytes[pos] != 0
            pos += 1
          end
          if pos >= end_of_page
            errmsg = "ERROR: end of page buffer when searching for string null start:#{start} pos:#{pos} eop:#{end_of_page} page_size:#{page_size}"
            break
          end
          pos += 1
          path = String.new bytes[start,(pos-start-1)]

          # read record_id, flags, and optionally node_id for version=2

          io.pos = pos
          record_id = io.read_bytes UInt64
          flags = io.read_bytes UInt32
          node_id = 0_u64
          if version > 1
            node_id = io.read_bytes UInt64
          end

          # notify listener

          status = listener.on_record(record_id, flags, path, node_id.to_s, io.pos.to_s)
          break if status == STATUS_ABORT

          #if (@verbose) { puts "#{record_id},#{flags.to_s(16)},#{path}" }
          i+=1

        rescue
          errmsg = "Exception reading page. pos:#{pos} page_size:#{page_size} io.pos:#{io.pos}"
          break
        end
      end

      # notify listener of end page

      listener.on_page_end io.pos, page_size.as(UInt32), errmsg
    end

  end

end
