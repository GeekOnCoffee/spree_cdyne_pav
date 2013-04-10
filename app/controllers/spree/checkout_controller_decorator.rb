Spree::CheckoutController.class_eval do

  alias_method :orig_update, :update

  def update
    if @order.state == "address"
      object_params[:ship_address_attributes][:is_shipping] = true
      # @order.assign_attributes(object_params)
      # @order.shipping_address.cdyne_update
      #@order.shipping_address.cdyne_address_valid?
    end
    orig_update
  end

end
