class Transaction
    include DataMapper::Resource

    property :id,          Serial 
    property :symbol,      String
    property :quantity,    Integer
    property :price,       Float
    property :executed_at, DateTime
    property :fee,         Float
    property :created_at,  DateTime

    belongs_to :portfolio

    def order_name
        if quantity > 0
            return "BUY "
        else
            return "SELL"
        end
    end

    def real_fee
        if fee == nil
            return 0
        else
            return fee
        end
    end
end


