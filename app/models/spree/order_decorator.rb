module Spree
  class Order < ActiveRecord::Base
    self.state_machine.before_transition :to => :delivery do |order|
      order.shipping_address.cdyne_update
      if order.shipping_address.cdyne_address_valid?
        true
      else
        false
      end
    end
  end
end
