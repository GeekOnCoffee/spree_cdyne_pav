Spree::Address.class_eval do
  attr_accessor :cdyne_override
  attr_accessible :cdyne_override

  def cdyne_update
    corrected_address = self.cdyne_address
    Rails.logger.error(corrected_address)
    self.address1 = corrected_address["PrimaryDeliveryLine"]
    self.address2 = corrected_address["SecondaryDeliveryLine"]
    self.city = corrected_address["CityName"]
    self.zipcode = corrected_address["ZipCode"] if corrected_address["ZipCode"].present?
    self.country =  Spree::Country.find_by_name(corrected_address["Country"]) if corrected_address["Country"].present?
    self.state = Spree::State.find_by_abbr(corrected_address["StateAbbreviation"]) if corrected_address["StateAbbreviation"].present?
    self.save
  end

  def cdyne_address_valid?
    cdyne_override || cdyne_address_status
  end

  def cdyne_address_status(status_code=cdyne_address["ReturnCode"])
    case status_code
    when 2
      raise "Invalid Cdyne License specified"
    when 10, 200
      return false
    when 100
      return true
    end
  end

  def cdyne_address_description(status_code=cdyne_address["ReturnCode"])
    case status_code
    when 2
      Rails.logger.error "Invalid Cdyne License specified"
    when 10
      "We are unable to find your address. Please verify that it is correct."
    when 100
      "Address Confirmed"
    when 101
      "Address found but not verified"
    when 102
      "Primary Address Confirmed, Cannot validate second address number"
    when 103
      "Primary Address Confirmed, Secondary address missing"
    end
  end

  def cdyne_address
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