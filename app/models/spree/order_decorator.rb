module Spree
  class Order < ActiveRecord::Base
    after_commit :switch_ship_address_id

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

    # Check to see if cdyne_validated instance var is set
    # If so, switch out user-entered address for CDYNE verified
    # address
    def switch_ship_address_id
      if ship_address && ship_address.cdyne_validated
        logger.info "In switch_ship_address_id ship_address is #{ship_address.inspect}"
        cdyne_id = self.ship_address.cdyne_address_id
        cdyne_address = Spree::Address.find(cdyne_id)
        self.update_attribute(:ship_address_id, cdyne_id)
      end
    end

  end
end
