require 'uri'
require 'json'
require 'net/http'

class StockFolio::Web
    def self.quote(symbol)
        url = "http://finance.google.com/finance/info?client=ig&q=#{symbol}"

        resp = Net::HTTP.get_response(URI.parse(url))
        data = resp.body

        if data.empty?
            return nil
        end
        JSON.parse(data.slice(3, data.length).strip)
    end

    def self.historical(symbol, startDate, endDate)
        s = startDate.strftime("%b+%d,+%Y")
        e = endDate.strftime("%b+%d,+%Y")
        url = "http://finance.google.com/finance/historical?q=#{symbol}&startdate=#{s}&enddate=#{e}&output=csv"
        puts " -> #{url}"

        resp = Net::HTTP.get_response(URI.parse(url))
        data = resp.body

        if data.empty?
            return nil
        end

        lines = data.split("\n")
        lines.shift
        items = []
        lines.each do |line|
            parts = line.split(",")
            i = 0
            item = {}
            item[:date]   = Date.parse(parts[0])
            item[:open]   = parts[1]
            item[:high]   = parts[2]
            item[:low]    = parts[3]
            item[:close]  = parts[4]
            item[:volume] = parts[5]
            items << item
        end

        items
    end

    def self.search(term)
        q = URI.escape(term, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
        url = "http://www.google.com/finance/match?matchtype=matchall&q=#{q}"
        resp = Net::HTTP.get_response(URI.parse(url))
        data = resp.body

        if data.empty?
            return nil
        end
        result = JSON.parse(data)
        result["matches"]
    end

end
