require "json"

class ReportQueryDef
  property name : String
  property sql : String
  def initialize(@name, @sql)
  end
end

class ReportUtils
  #----------------------------------------------------------------------
  # parses report_queries.json
  # { process_list: [ { report_name: "blah", query: "CREATE VIEW..."} ] }
  #----------------------------------------------------------------------
  def self.parse_json(filepath : String)
    retval = [] of ReportQueryDef
    File.open(filepath, "r") do |io|
      obj = JSON.parse(io)
      obj["process_list"].as_a.each do |row|
        retval.push ReportQueryDef.new row["report_name"].as_s, row["query"].as_s
      end
    end
    return retval
  end
end

# Progress : A simple class that prints out 10%, 20%, etc.
class Progress

  #----------------------------------------------------------------------
  # constructor - pass the total number of increment() calls expected
  #----------------------------------------------------------------------
  def initialize(limit : UInt32 | Int32)
    @limit = 100_u32
    raise "Invalid limit parameter" if limit <= 0
    @limit = limit.to_u32
    @i = 0
    @pct = 0
    @percentStep = 10
  end

  def increment()
    @i += 1
    pct = (100.0 * @i) / @limit
    if pct >= (@pct + @percentStep)

      @pct += @percentStep

      if @stepBlock.nil?
        puts "#{@pct}%"
      else
        @stepBlock.not_nil!.call @pct
      end
    end
  end

  #----------------------------------------------------------------------
  # optional : provide alternate handler for each step
  #----------------------------------------------------------------------
  def every(percentStep : UInt32, &block : Int32 -> )
    raise "Invalid percentStep #{percentStep}" if percentStep < 1 || percentStep > 25
    @percentStep = percentStep
    @stepBlock = block
  end

end
