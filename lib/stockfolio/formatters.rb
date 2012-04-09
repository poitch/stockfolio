require 'hirb'

module Hirb::Helpers::Table::Filters
    def to_dollars(amount)
        if amount
            amount = amount.to_f
            if amount < 0
                sprintf('($%0.2f)',0-amount).gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
            else
                sprintf('$%0.2f',amount).gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
            end
        end
    end

    def to_percent(value)
        if value
            "#{(100.0 * value).round(1)}%"
        end
    end
end

