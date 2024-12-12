module CurrencyHelper
  def naira(amount)
    return "₦0.00" if amount.nil?
    
    if amount >= 1_000
      "₦#{number_to_human(amount, 
        precision: 1,
        units: {
          thousand: 'K',
          million: 'M',
          billion: 'B',
          trillion: 'T'
        },
        format: '%n%u'
      )}"
    else
      "₦#{number_with_delimiter(amount.round(2), delimiter: ',')}"
    end
  end
end 