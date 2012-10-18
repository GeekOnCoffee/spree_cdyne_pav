module Spree
  class Order < ActiveRecord::Base
    attr_accessible :use_corrected_address
    attr_accessor :use_corrected_address
    
  end
end
