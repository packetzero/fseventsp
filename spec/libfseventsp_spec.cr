require "./spec_helper"

struct Rec
  property id : UInt64
  property flags : UInt32
  property path : String
  def initialize(@id, @flags, @path)
  end
  def to_csv
    "#{id},#{flags.to_s(16)},#{path}"
  end
end


# obtain portions of files using:
#  gzcat file > file-uncompressed.bin
#  head -c 298 file-uncompressed.bin | hexdump -v -e '298/1 "%02x"' -e '"\n"'

# TESTA
# 6902249,800018,Library/Application Support/Antivirus for Mac/Cache/-1149469724
# 6902282,800018,Library/Application Support/Antivirus for Mac/Cache/-1791658546
# 6902304,800018,Library/Application Support/Antivirus for Mac/Cache/-258097524

TESTA="32534c44b8816b8db9ff03004c6962726172792f4170706c69636174696f6e20537570706f72742f416e7469766972757320666f72204d61632f43616368652f2d3131343934363937323400e9516900000000001800800029e01300020000004c6962726172792f4170706c69636174696f6e20537570706f72742f416e7469766972757320666f72204d61632f43616368652f2d31373931363538353436000a52690000000000180080002ce01300020000004c6962726172792f4170706c69636174696f6e20537570706f72742f416e7469766972757320666f72204d61632f43616368652f2d323538303937353234002052690000000000180080002ee0130002000000"

class TestParserListener < FSE::ParserListener
  property records = [] of Rec
  property page_size = 0_u32
  property page_end_errmsg = ""
  property filename = ""

  def on_file(filename : String)
    @filename = filename
  end

  def on_page(version : Int32, page_size : UInt32)
    @page_size = page_size
  end

  # if bytes_processed < page_size, the file was incomplete, or other error
  def on_page_end(readlen : Int32|UInt32, page_size : UInt32, errmsg : String)
    @page_end_readlen = readlen
    @page_end_errmsg = errmsg
  end

  def on_record(record_id : UInt64, flags : UInt32, path : String, node_id : String, record_end_offset : String)
    @records.push Rec.new record_id, flags, path
  end

end

def hex_to_io(hexstr)
  io = IO::Memory.new
  io.write hexstr.hexbytes
  io.rewind
  io
end

describe Libfseventsp do

  it "parses version 2 short-io uncompressed" do
    listener = TestParserListener.new

    obj = FSE::Parser.new

    io = hex_to_io TESTA
    obj.test_process_file io, listener

    listener.records.size.should eq 3
    (listener.page_end_errmsg.size > 0).should eq true

    rec = listener.records[0]
    rec.to_csv.should eq "6902249,800018,Library/Application Support/Antivirus for Mac/Cache/-1149469724"

    rec = listener.records[2]
    rec.id.should eq 6902304
    rec.flags.should eq 0x800018
    rec.path.should eq "Library/Application Support/Antivirus for Mac/Cache/-258097524"

  end

  it "parses version 2 short-file" do
    listener = TestParserListener.new

    obj = FSE::Parser.new

    obj.read "spec/data/testa-v2.bin.gz", listener

    listener.records.size.should eq 3
    (listener.page_end_errmsg.size > 0).should eq true

    rec = listener.records[0]
    rec.to_csv.should eq "6902249,800018,Library/Application Support/Antivirus for Mac/Cache/-1149469724"

    rec = listener.records[2]
    rec.id.should eq 6902304
    rec.flags.should eq 0x800018
    rec.path.should eq "Library/Application Support/Antivirus for Mac/Cache/-258097524"

  end

end
