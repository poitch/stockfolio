class Portfolio
    include DataMapper::Resource

    property :id,         Serial 
    property :name,       String
    property :created_at, DateTime

    has n, :transactions
end

