Spree::CheckoutController.class_eval do

  alias_method :update_without_cdyne, :update

  def update
    if @order.state == "address"
      if params[:order].delete(:use_original_address)  
        Rails.logger.info("Checkout Update: use_original_address")
        @order.update_attributes(object_params)
        fire_event('spree.checkout.update')
        @order.next
      else
        Rails.logger.info("Checkout Update: first_time")
        @order.update_attributes(object_params)
        fire_event('spree.checkout.update')
        @order.shipping_address.cdyne_update

        if @order.shipping_address.cdyne_address_valid?
          Rails.logger.info("Checkout Update: valid")
          params[:order].delete("ship_address_attributes")
          @order.ship_address.reload
          cdyne_id = @order.shipping_address.cdyne_address_id

          @order.next
          @order.ship_address.reload
          @order.reload
          Rails.logger.info("Checkout Update: #{cdyne_id}")
          @order.update_attribute(:ship_address_id, cdyne_id)
          Rails.logger.info("Checkout Update: done with order.next")
        else
          Rails.logger.info("Checkout Update: error")
          flash[:error] = @order.shipping_address.cdyne_address_description
        end
      end
      respond_with(@order, :location => checkout_state_path(@order.state))
      return
    end

    update_without_cdyne
  end
end
