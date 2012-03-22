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
end
