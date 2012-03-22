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

    def quote(symbol)
        quote = StockFolio::Web.quote(symbol)
        print_quotes(quote)
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
        else
            portfolios = Portfolio.all(:name => name)
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
        positions.each do |symbol,position|
            p = {}
            p["Symbol"] = symbol.split(":")[1]
            p["Last Price"] = "$#{position[:l].to_f.round(2)}"
            p["Change"] = "#{position[:c]} (#{position[:cp]}%)"

            if position[:quantity] > 0
                p["Day's Gain"] = (position[:quantity] * position[:c].to_f).round(2)
                p["Shares"] = position[:quantity]
                p["Cost Basis"] = "$#{position[:cost].round(2)}"
                p["Market Value"] = "$#{position[:value].round(2)}"
                p["Gain"] = "$#{(position[:value] - position[:cost]).round(2)}"
                p["Gain %"] = "#{(100.0 * (position[:value] - position[:cost]) / position[:cost]).round(1)}%"
            else
                p["Gain"] = "$#{(0 - position[:balance]).round(2)}"
                p["Gain %"] = "#{(100.0 * (0 - position[:balance]) / position[:cost]).round(1)}%"
            end
            pos << p
        end

        puts Hirb::Helpers::Table.render(pos, :fields => ["Symbol", "Last Price", "Change", "Day's Gain", "Shares", "Cost Basis", "Market Value", "Gain", "Gain %"])
        
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
        Portfolio.create(:name => name, :created_at => DateTime.now)
    end

    desc 'Add to watchlist'
    def watch(symbol)
        # Validate symbol
        quote = StockFolio::Web.quote(symbol)
        if nil != quote
            quote.each do |q|
                WatchList.create(
                    :symbol => "#{q["e"]}:#{q["t"]}",
                    :created_at => DateTime.now
                )
                puts "Added #{q["t"]}"
            end
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
        puts "Portfolio #{portfolio.id} - #{portfolio.name}"

        # Validate the symbol
        quote = StockFolio::Web.quote(options[:symbol])
        if nil == quote
            puts "Symbol #{options[:symbol]} not found"
            return
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

    end

    def print_quotes(quote)
        if nil != quote
            # Beautify those
            quote.each do |q|
                q["Symbol"] = q["t"]
                q["Last Price"] = "$#{q["l"]}"
                q["Change"] = "#{q["c"]} (#{q["cp"]}%)"
            end
            puts Hirb::Helpers::Table.render(quote, fields: ["Symbol", "Last Price", "Change"])
        end
 
    end
end
