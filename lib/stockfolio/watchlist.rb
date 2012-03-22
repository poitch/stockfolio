class WatchList
    include DataMapper::Resource

    property :id,         Serial 
    property :symbol,     String
    property :created_at, DateTime
end

