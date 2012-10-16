module Spree
  class Order < ActiveRecord::Base
    attr_accessible :cdyne_override, :cdyne_overridden
    attr_accessor :cdyne_overridden
    
    def cdyne_override
      self.ship_address_id = self.ship_address.cdyne_address_id
      self.save
    end
    
    self.state_machine.before_transition :to => :delivery do |order|
      unless order.cdyne_overridden
        order.shipping_address.cdyne_update
        if order.shipping_address.cdyne_address_valid?
          true
        else
          false
        end
      end
    end
  end
end
