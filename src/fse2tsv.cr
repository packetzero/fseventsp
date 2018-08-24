require "./libfseventsp/*"

listener = TsvWriter.new
if ARGV.size > 1
  listener.write_header_is_enabled = false if ARGV[0] == "--noheader"
end
filename = ARGV.last
obj = FSE::Parser.new
obj.read filename, listener
