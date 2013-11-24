require 'data_mapper' # requires all the gems listed above
require  'dm-migrations'

require File.join(File.dirname(__FILE__), 'stockfolio/portfolio')
require File.join(File.dirname(__FILE__), 'stockfolio/transaction')
require File.join(File.dirname(__FILE__), 'stockfolio/watchlist')
require File.join(File.dirname(__FILE__), 'stockfolio/formatters')

module StockFolio
    autoload :Runner, 'stockfolio/runner'
    autoload :Web, 'stockfolio/web'
    autoload :ConsoleGraph, 'stockfolio/consolegraph'
end

#DataMapper::Logger.new($stdout, :debug)

rcfile = ENV['STOCKFOLIO_YML'] || Dir.home + '/.stockfolio.yml'

if File.exists?(rcfile)
    config = YAML::load(File.open(rcfile))
    ENV['STOCKFOLIO_DB'] = config['db'] || nil
    if (config[:database])
        ENV['STOCKFOLIO_DB'] = config[:database][:location] || nil
    end
end

dbfile = ENV['STOCKFOLIO_DB'] || Dir.home + '/.stockfolio.db'
dbfile = File.expand_path(dbfile)

# A Sqlite3 connection to a persistent database
DataMapper.setup(:default, "sqlite://#{dbfile}")

DataMapper.finalize
DataMapper.auto_upgrade!

