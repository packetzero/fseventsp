#require "sqlite3"

class EventsDB

  #----------------------------------------------------------------------
  # create sqlite3 database file and populate with TSV data
  # the dot commands are not supported by crystal sqlite3 driver
  #----------------------------------------------------------------------
  def self.create(tsv_filepath : String, dbpath : String)

    File.delete(dbpath) if File.exists?(dbpath)

    str =<<-EOS
CREATE TABLE fsevents (id INTEGER,fullpath TEXT,filename TEXT,type TEXT,flags TEXT,approx_dates_plus_minus_one_day DATE,mask INTEGER,node_id TEXT,record_end_offset INTEGER,source TEXT,source_modified_time DATETIME);
.mode tabs
.import \"#{tsv_filepath}\" fsevents
EOS
    # execute sqlite3 command in subshell

    puts "creating database and importing TSV"

    `echo "#{str}" | sqlite3 "#{dbpath}"`

    puts "creating fullname index..."

    `sqlite3 "#{dbpath}" "CREATE INDEX idx_fse_fullpath ON fsevents(fullpath)"`
  end

  #----------------------------------------------------------------------
  # runs sqlite3 with each query sql
  #----------------------------------------------------------------------
  def self.generate_reports(dbpath : String, items : Array(ReportQueryDef) )
    items.each do |item|
      puts "creating report '#{item.name}'"
      `echo "#{item.sql}" | sqlite3 "#{dbpath}"`
    end
  end
end
