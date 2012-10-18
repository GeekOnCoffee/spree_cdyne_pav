Spree::CheckoutController.class_eval do
  
  def update
    if @order.state == "address"        
      if params[:order].delete(:use_original_address)  
        Rails.logger.info("Checkout Update: use_corrected_address")
        params[:order].delete("ship_address_attributes")
        @order.next
        @order.ship_address_id = @order.ship_address.cdyne_address_id
        @order.save!
      elsif @order.ship_address and @order.ship_address.cdyne_address
        @order.ship_address.update_attribute(:cdyne_address, nil)
        Rails.logger.info("Checkout Update: addresses defined")
        params[:order].delete("ship_address_attributes")
        @order.save!
        @order.next
        @order.save!
      else
        Rails.logger.info("Checkout Update: first_time")
        @ord
        @order.update_attributes(object_params)
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
          flash[:retry_address] = true
        end
      end      
      respond_with(@order, :location => checkout_state_path(@order.state))
      return
    end
    
    if @order.update_attributes(object_params)
      fire_event('spree.checkout.update')

      if @order.next
        state_callback(:after)
      else
        flash[:error] = t(:payment_processing_failed)
        respond_with(@order, :location => checkout_state_path(@order.state))
        return
      end

      if @order.state == "complete" || @order.completed?
        flash.notice = t(:order_processed_successfully)
        flash[:commerce_tracking] = "nothing special"
        respond_with(@order, :location => completion_route)
      else
        respond_with(@order, :location => checkout_state_path(@order.state))
      end
    else
      respond_with(@order) { |format| format.html { render :edit } }
    end
  end
  
  #def update
  #  if params[:order].delete(:cdyne_override)
  #    cdyne_override = true
  #    params[:order].delete("bill_address_attributes")
  #    params[:order].delete("ship_address_attributes")
  #  end
  #
  #  if @order.update_attributes(object_params)
  #    fire_event('spree.checkout.update')
  #
  #    if @order.next
  #      state_callback(:after)
  #      if cdyne_override
  #        @order.cdyne_override
  #        @order.cdyne_overridden = true
  #      end
  #    else
  #      if @order.state == "address"
  #        flash[:error] = @order.shipping_address.cdyne_address_description
  #        flash[:retry_address] = true
  #      else
  #        flash[:error] = t(:payment_processing_failed)
  #      end
  #      
  #      respond_with(@order, :location => checkout_state_path(@order.state))
  #      return
  #    end
  #
  #    if @order.state == "complete" || @order.completed?
  #      flash.notice = t(:order_processed_successfully)
  #      flash[:commerce_tracking] = "nothing special"
  #      respond_with(@order, :location => completion_route)
  #    else
  #      respond_with(@order, :location => checkout_state_path(@order.state))
  #    end
  #  else
  #    respond_with(@order) { |format| format.html { render :edit } }
  #  end
  #end
  
end