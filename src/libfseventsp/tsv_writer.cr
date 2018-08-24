#require "./*"

class TsvWriter < FSE::ParserListener
  property modtime : Time | String
  property write_header_is_enabled = true


  HEADER_ROW="id\tfullpath\tfilename\ttype\tflags\tapprox_dates_plus_minus_one_day\tmask\tnode_id\trecord_end_offset\tsource\tsource_modified_time"

  def initialize(@outio : IO = STDOUT)
    @page_size = 0_u32
    @i = 0
    @filename = ""
    @modtime = ""
#    @outio = outio
  end

  def on_file(filename : String)
    @filename = File.basename filename
    info = File.info(filename)
    @modtime = info.modification_time
    @outio.puts HEADER_ROW if @write_header_is_enabled

  end

  def self.get_create_table_stmt
    "CREATE TABLE (#{HEADER_ROW.gsub("\t",",")});"
  end

  def on_page(version : Int32, page_size : UInt32)
    @page_size = page_size
    @i = 0
  end

  # if bytes_processed < page_size, the file was incomplete, or other error
  def on_page_end(readlen : Int32|UInt32, page_size : UInt32, errmsg : String)
    if errmsg.size > 0
      STDERR.puts errmsg
    end
  end

  def on_record(record_id : UInt64, flags : UInt32, path : String, node_id, record_end_offset)
    event_flag_names = EventFlags.new((flags & MASK_WITHOUT_TYPE).to_i).to_s.gsub(" | ",";")
    event_type_name = EventFlags.new((flags & MASK_ONLY_TYPE).to_i).to_s.gsub(" | ",";")

    fname = File.basename(path)

    fields = [ record_id, path, fname, event_type_name, event_flag_names, @modtime, flags, node_id, record_end_offset, @filename, @modtime ]

    @outio.puts fields.join('\t')

    @i += 1
  end
end
