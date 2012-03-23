require 'stockfolio/version'
require 'gems'

class StockFolio::Check

    def self.has_newer
        @info = Gems.info 'stockfolio'
        Gem::Version.new(@info["version"]) > Gem::Version.new(StockFolio::VERSION)
    end

    def self.version_available
        return @info["version"]
    end

end
