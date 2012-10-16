Spree::CheckoutController.class_eval do
  
  def update
    if params[:order].delete("cdyne_override")
      @order.cdyne_override
      @order.cdyne_overridden = true
    end

    if @order.update_attributes(object_params)
      fire_event('spree.checkout.update')

      if @order.next
        state_callback(:after)
      else
        if @order.state == "address"
          flash[:error] = @order.shipping_address.cdyne_address_description
          flash[:retry_address] = true
        else
          flash[:error] = t(:payment_processing_failed)
        end
        
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
  
end