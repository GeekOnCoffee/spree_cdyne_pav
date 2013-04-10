module Spree
  class Order < ActiveRecord::Base

    # Redefine clone_billing_address to ensure that is_shipping
    # is true on shipping attribute

    def clone_billing_address
      if bill_address and self.ship_address.nil?
        self.ship_address = bill_address.clone
      else
        self.ship_address.attributes = bill_address.attributes.except('id', 'updated_at', 'created_at')
      end
      ship_address.is_shipping = true
      true
    end

  end
end
