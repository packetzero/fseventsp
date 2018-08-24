require "option_parser"
require "./libfseventsp/*"

# immitates FSEventParser.py by G-C Partners
# https://github.com/dlcowen/FSEventsParser

sourceDir = ""
destDir = "./out"
queryFile = ""

OptionParser.parse! do |parser|
  parser.banner = "Usage: fseventp [arguments]"
  parser.on("-s SOURCEDIR", "--sourcedir=PATH", "Directory containing fsevents files") { |value| sourceDir = value }
  parser.on("-o OUTDIR", "--ourdir=PATH", "Output directory. Defaults to ./out/") { |value| destDir = value }
  parser.on("-q REPORT_QUERIES", "--queryfile=PATH", "Path to reports.json file containing queries to run on data.") { |value| queryFile = value }
  parser.on("-h", "--help", "Show this help") { puts parser }
end

unless sourceDir.size > 0
  puts "missing required sourcedir argument"
  exit 3
end

Dir.mkdir_p(destDir)
tsvFile = File.open(File.join(destDir, "events.tsv"), "w")

listener = TsvWriter.new tsvFile
listener.write_header_is_enabled = false

# get list of files

filenames = [] of String
Dir.open(sourceDir).each do |file|
  next unless file.starts_with?("00")
  filenames.push file
end

# check
if filenames.empty?
  puts "ERROR: no files in source directory '#{sourceDir}' ?"
  exit 4
end

# sort and process
filenames.sort!
filenames.each do |file|
  puts "File:#{file}"
  obj = FSE::Parser.new
  obj.read File.join(sourceDir,file), listener
end
