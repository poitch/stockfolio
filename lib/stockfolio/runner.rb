require 'boson/runner'
require 'hirb'

class StockFolio::Runner < Boson::Runner

    def self.common_transaction_options
        option :portfolio, :type => :string, :desc => 'Portfolio name', :required => true
        option :symbol, :type=>:string, :desc => 'Symbol of stock', :required => true
        option :price, :type => :numeric, :desc => 'Price paid', :required => true
        option :quantity, :type => :numeric, :desc => 'Quantity', :required => true
        option :fee, :type => :numeric, :desc => 'Transaction fee'
        option :date, :type => :string, :desc => 'Transaction date'
    end

    def version
        require 'stockfolio/version'
        require 'stockfolio/check'
        puts StockFolio::VERSION
        if StockFolio::Check.has_newer
            puts "There is a more recent version #{StockFolio::Check.version_available}"
        end
    end

    desc "Current quote for a stock"
    def quote(symbol)
        quote = StockFolio::Web.quote(symbol)
        print_quotes(quote)
    end

    desc "Historical prices for a stock"
    def historical(symbol,start_date,end_date)
        history = StockFolio::Web.historical(symbol, DateTime.parse(start_date), DateTime.parse(end_date))
        puts Hirb::Helpers::Table.render(history, :fields => [:date, :open, :close, :low, :high, :volume])
        # http://tagaholic.me/hirb/doc/classes/Hirb/Helpers/Table.html#M000008
        # :headers => { :date => "Date", ... }
        # :description => false
        # :filters => { :date => lambda { |f} }}
        # https://github.com/change/method_profiler/blob/master/lib/method_profiler/hirb.rb
    end

    def graph_historical(symbol,start_date,end_date)
        history = StockFolio::Web.historical(symbol, DateTime.parse(start_date), DateTime.parse(end_date))

        values = []
        history.each do |row|
            values << row[:close]
        end
        values.reverse!
        StockFolio::ConsoleGraph.new(values)
    end

    desc "Search symbol"
    def search(term)
        matches = StockFolio::Web.search(term)

        lines = []
        matches.each do |match|
            if match['e'].length > 0 && match['t'].length > 0
            line = {
                :Symbol => "#{match['e']}:#{match['t']}",
                :Name => match['n']
            }
            lines << line
            end
        end

        puts Hirb::Helpers::Table.render(lines, :fields => [:Symbol, :Name])

    end

    desc 'List porfolios'
    def portfolios
        q = Portfolio.all
        portfolios = []
        q.each do |p|
            portfolios << {
                :name => p.name,
                :created_at => p.created_at
            }
        end

        puts Hirb::Helpers::Table.render(portfolios, :fields => [:name, :created_at])
    end

    desc 'Current positions'
    def positions(name = nil)
        portfolios = []
        if nil == name
            portfolios = Portfolio.all
            if portfolios.size == 0
                puts "No portfolio found"
                exit
            end
        else
            portfolios = Portfolio.all(:name => name)
            if portfolios.size == 0
                puts "Portfolio #{name} not found"
                exit
            end
        end

        positions = {}
        portfolios.each do |portfolio|
            #puts "Positions for #{portfolio.name}"
            portfolio.transactions.each do |transaction|
                #puts "#{transaction.order_name} #{transaction.quantity} #{transaction.symbol}"
                if positions[transaction.symbol]
                    positions[transaction.symbol][:quantity] = positions[transaction.symbol][:quantity] + transaction.quantity
                    #if transaction.quantity > 0
                        positions[transaction.symbol][:cost] = positions[transaction.symbol][:cost] + transaction.quantity * transaction.price + transaction.real_fee
                    #end
                    positions[transaction.symbol][:balance] = positions[transaction.symbol][:balance] + transaction.quantity * transaction.price + transaction.real_fee
                else
                    positions[transaction.symbol] = {
                        :symbol => transaction.symbol,
                        :cost => transaction.quantity * transaction.price + transaction.real_fee,
                        :balance => transaction.quantity * transaction.price,
                        :quantity => transaction.quantity
                    }
                end
            end
        end

        # Get current prices
        quotes = StockFolio::Web.quote(positions.keys.join(","))
        quotes.each do |q|
            symbol = "#{q["e"]}:#{q["t"]}"
            positions[symbol][:l] = q["l"]
            positions[symbol][:c] = q["c"]
            positions[symbol][:cp] = q["cp"]
            positions[symbol][:value] = positions[symbol][:quantity] * q["l"].to_f
        end

        pos = []

        total = {}
        total[:symbol] = "Total"
        total[:daygain] = 0
        total[:cost] = 0
        total[:value] = 0
        total[:gain] = 0

        positions.each do |symbol,position|
            p = {}
            p[:symbol] = symbol.split(":")[1]
            p[:last_price] = position[:l].to_f
            p[:change] = "#{position[:c]} (#{position[:cp]}%)"

            if position[:quantity] > 0
                p[:daygain] = position[:quantity] * position[:c].to_f
                p[:quantity] = position[:quantity]
                p[:cost] = position[:cost].to_f
                p[:value] = position[:value].to_f
                p[:gain] = position[:value] - position[:cost]
                p[:gain_p] = (position[:value] - position[:cost]) / position[:cost]

                total[:daygain] = total[:daygain] + p[:daygain]
                total[:cost] = total[:cost] + position[:cost]
                total[:value] = total[:value] + position[:value]
                total[:gain] = total[:gain] + position[:value] - position[:cost]
            else
                p[:gain] = (0 - position[:balance])
                p[:gain_p] = (0 - position[:balance]) / position[:cost]

            end
            pos << p
        end

        pos.sort! { |a,b| a[:symbol] <=> b[:symbol] }

        total[:gain_p] = (total[:value] - total[:cost]) / total[:cost]

        pos << total

        puts Hirb::Helpers::Table.render(pos, 
            :fields => [:symbol, :last_price, :change, :daygain, :quantity, :cost, :value, :gain, :gain_p],
            :headers => {:symbol => "Symbol", :last_price => "Last Price", :change => "Change", :daygain => "Day's Gain", :quantity => "Shares", :cost => "Cost Basis", :value => "Market Value", :gain => "Gain", :gain_p => "Gain %"},
            :filters => { :last_price => :to_dollars, :daygain => :to_dollars, :cost => :to_dollars, :value => :to_dollars, :gain => :to_dollars, :gain_p => :to_percent },
            :description => false

                                        )
        puts "Market is #{StockFolio::Web.market_status}"
    end

    common_transaction_options
    desc 'Add buy transaction'
    def buy(options={})
        transaction = transaction_from_options(options)
    end

    common_transaction_options
    desc 'Add sell transaction'
    def sell(options={})
        options[:quantity] = 0 - options[:quantity]
        transaction = transaction_from_options(options)
    end

    desc 'Create Portfolio'
    def create(name)
        p = Portfolio.all(:name => name)
        if p.size > 0
            puts "Portfolio \"#{name}\" already exists"
            exit
        end

        Portfolio.create(:name => name, :created_at => DateTime.now)
        puts "Created portfolio \"#{name}\""
    end

    desc 'List transactions for a portfolio'
    def transactions(name)
        p = Portfolio.first(:name => name)
        if p == nil
            puts "Portfolio #{name} not found"
            exit
        end

        transactions = []
        p.transactions.each do |transaction|
            transactions << {
                :id => transaction.id,
                :symbol => transaction.symbol,
                :quantity => transaction.quantity,
                :price => transaction.price,
                :executed_at => transaction.executed_at,
                :fee => transaction.fee,
                :created_at => transaction.created_at
            }
        end
        puts Hirb::Helpers::Table.render(transactions, fields: [:id, :symbol, :quantity, :price, :fee, :executed_at, :created_at])

    end

    def delete(type,alpha,beta = nil)
        if type == "transaction"
            name = alpha
            id = beta
            puts "Deleting transaction #{id} from #{name}"

            portfolio = Portfolio.first(:name => name)
            if portfolio == nil
                puts "Portfolio #{name} not found"
                exit
            end

            transaction = Transaction.get(id)

            if transaction != nil && transaction.portfolio == portfolio
                transaction.destroy!
            else
                puts "Could not find transaction #{id} in portfolio #{name}"
            end

        elsif type == "portfolio"
            name = alpha
            puts "Deleting portfolio #{name}"

            portfolio = Portfolio.first(:name => name)
            if portfolio == nil
                puts "Portfolio #{name} not found"
                exit
            end

            portfolio.transactions.each do |transaction|
                transaction.destroy!
            end
            portfolio.destroy!

        end
    end

    #
    # WATCHLIST
    # 

    desc 'Add to watchlist'
    def watch(symbol)
        # Validate symbol
        quote = StockFolio::Web.quote(symbol)
        if nil != quote
            quote.each do |q|
                item = WatchList.create(
                    :symbol => "#{q["e"]}:#{q["t"]}",
                    :created_at => DateTime.now
                )
                puts "Added #{item.symbol} to watchlist - current price $#{q['l']}"
            end
        end
    end

    desc 'Remove from watchlist'
    def unwatch(symbol)
        item = WatchList.first(:symbol => symbol)
        if item != nil
            item.destroy
            puts "Removed #{symbol} from watchlist"
        end
    end

    desc 'Show Watchlist'
    def watchlist
        items = WatchList.all(:order => [:symbol.asc])
        symbols = []
        items.each do |item|
            symbols << item.symbol
        end
        quote = StockFolio::Web.quote(symbols.join(",")) 
        print_quotes(quote)
    end

    private
    def transaction_from_options(options={})
        # Do we have this portfolio?!?
        portfolios = Portfolio.all(:name => options[:portfolio])
        if portfolios.size == 0
            puts "Portfolio #{options[:portfolio]} does not exist"
            return
        end

        portfolio = portfolios[0]

        # Validate the symbol
        quote = StockFolio::Web.quote(options[:symbol])
        if nil == quote
            puts "Symbol \"#{options[:symbol]}\" not found"
            exit
        end

        transaction = Transaction.new(
                :symbol => options[:symbol],
                :quantity => options[:quantity],
                :price => options[:price],


                :fee => 0,
                :portfolio => portfolio,
                :executed_at => DateTime.now,
                :created_at => DateTime.now
        )
        transaction.fee = options[:fee] if options[:fee]
        transaction.executed_at = DateTime.parse(options[:date]) if options[:date]
        transaction.save

        puts "Added #{transaction.order_name} of #{transaction.quantity} #{transaction.symbol} to #{portfolio.name}"

    end

    def print_quotes(quote)
        if nil != quote
            # Beautify those
            extended = false
            quote.sort! { |a,b| a["t"] <=> b["t"] }
            quote.each do |q|
                #q["Symbol"] = q["t"]
                #q["Last Price"] = "$#{q["l"]}"

                #q["t"] = "#{q["e"]}:#{q["t"]}"
                q[:change] = "#{q["c"]} (#{q["cp"]}%)"
                if q["el"]
                    q[:echange] = "#{q["ec"]} (#{q["ecp"]}%)"
                    extended = true
                else
                    q["elt"] = q["lt"]
                end
            end
            headers = { "t" => "Symbol", "l" => "Last Price", :change => "Change", "lt" => "Last Updated" }
            
            fields = ["t", "l", :change, "lt"]
            filters = { "l" => :to_dollars }

            if extended
                fields = ["t", "l", :change, "el", :echange, "elt"]
                headers = { "t" => "Symbol", "l" => "Close Price", :change => "Change", "el" => "After Hours Price", :echange => "After Hours Change", "elt" => "Last Updated" }
                filters = { "l" => :to_dollars, "el" => :to_dollars }
            end

            puts Hirb::Helpers::Table.render(quote, 
                     :fields => fields,
                     :headers => headers,
                     :filters => filters,
                     :description => false
            )
        end
 
    end
end
