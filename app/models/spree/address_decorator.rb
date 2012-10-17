Spree::Address.class_eval do
  attr_accessor :cdyne_override
  attr_accessible :cdyne_override, :cdyne_address_id
  
  has_one :cdyne_address, :class_name => "Spree::Address", :foreign_key => :cdyne_address_id

  def cdyne_update
    corrected_address = self.cdyne_address_response
    
    if cdyne_address_status
      address = self
    else
      address = self.class.new
    end
    
    
      address.firstname = self.firstname
      address.lastname = self.lastname
      address.address1 = corrected_address["PrimaryDeliveryLine"]
      address.address2 = corrected_address["SecondaryDeliveryLine"]
      address.city = corrected_address["CityName"]
      address.zipcode = corrected_address["ZipCode"].presence || self.zipcode
      address.country =  Spree::Country.find_by_name(corrected_address["Country"]) || self.country
      address.phone = self.phone
      address.state = Spree::State.find_by_abbr(corrected_address["StateAbbreviation"]) || self.state
      address.save!
      
    unless cdyne_address_status
      self.update_attribute(:cdyne_address_id, address.id)
    end

  end

  def cdyne_address_valid?
    cdyne_address_status
  end

  def cdyne_address_status(status_code=cdyne_address_response["ReturnCode"])
    case status_code
    when 2
      raise "Invalid Cdyne License specified"
    when 10, 200
      return false
    when 100
      return true
    end
  end

  def cdyne_address_description(status_code=cdyne_address_response["ReturnCode"])
    case status_code
    when 2
      Rails.logger.error "Invalid Cdyne License specified"
    when 10
      "We are unable to find your address.  Please correct or \"Use Original Address\""
    when 100
      "Address Confirmed"
    when 101
      "Address found but not verified"
    when 102
      "Primary Address Confirmed, Cannot Validate Second Address. Please correct or \"Use Original Address\""
    when 103
      "Primary Address Confirmed, Secondary address missing. Please correct or \"Use Original Address\""
    end
  end

  def cdyne_address_response
    @request ||= HTTParty.post('http://pav3.cdyne.com/PavService.svc/VerifyAddressAdvanced', :body => cdyne_query_hash, :headers => {"content-type" => "application/json"})
    return @request.parsed_response
  end
  
  private
  def cdyne_query_hash
    {
      :FirmOrRecipient => [firstname, lastname].join(" "), 
      :PrimaryAddressLine=> address1,
      :SecondaryAddressLine => address2,
      :CityName=> city,
      :State=>state_text,
      :ZipCode=>zipcode,
      :LicenseKey=> Spree::Config.cdyne_license_key
      }.to_json
  end
  
end