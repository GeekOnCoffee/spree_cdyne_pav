Spree::CheckoutController.class_eval do

  alias_method :orig_update, :update

  def update
    if @order.state == "address"
      object_params[:ship_address_attributes][:is_shipping] = true if object_params[:ship_address_attributes]
    end
    orig_update
  end

end
