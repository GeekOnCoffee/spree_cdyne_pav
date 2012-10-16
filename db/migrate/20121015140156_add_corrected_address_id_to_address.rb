class AddCorrectedAddressIdToAddress < ActiveRecord::Migration
  def change
    add_column :spree_addresses, :cdyne_address_id, :integer
  end
end
