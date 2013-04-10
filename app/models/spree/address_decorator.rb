Spree::Address.class_eval do
  attr_accessor :cdyne_override
  attr_accessor :is_shipping
  attr_accessible :cdyne_override, :cdyne_address_id, :is_shipping

  has_one :cdyne_address, :class_name => "Spree::Address", :foreign_key => :cdyne_address_id

  validate :must_by_cdyne_valid

  def must_by_cdyne_valid
    if is_shipping && country.iso3 == "USA"
      cdyne_update
      status_code=cdyne_address_response["ReturnCode"]
      case status_code
      when 1
        errors.add(:base, I18n.t('cdyne.errors.1_invalid_input'))
      when 2
        raise "Invalid Cdyne License specified"
      when 10
        errors.add(:base, I18n.t('cdyne.errors.10_not_found'))
        return true
      when 100, 101, 200
        return true
      when 102, 202
        errors.add(:address2, I18n.t('cdyne.errors.103_address_2_missing'))
      when 103
        errors.add(:address2, I18n.t('cdyne.errors.103_address_2_missing'))
        return true
      end
    end
  end

  def cdyne_update
    # return true unless self.country.iso3 == "USA"
    corrected_address = self.cdyne_address_response
    Rails.logger.info "Corrected address is #{corrected_address.inspect}"

    address = self.class.new

    address.firstname = self.firstname
    address.lastname = self.lastname
    address.address1 = corrected_address["PrimaryDeliveryLine"]
    address.address2 = corrected_address["SecondaryDeliveryLine"]
    address.city = corrected_address["CityName"]
    address.zipcode = corrected_address["ZipCode"].presence || self.zipcode
    address.country =  Spree::Country.find_by_name(corrected_address["Country"]) || self.country
    address.phone = self.phone
    address.state = Spree::State.find_by_abbr(corrected_address["StateAbbreviation"]) || self.state
    address.cdyne_address_id = self.id

    if address.save
      self.update_attribute(:cdyne_address_id, address.id)
    end
    logger.info "CDYNE Address is #{address.inspect}"
  end

  # def cdyne_address_valid?
  #   return true unless self.country.iso3 == "USA"
  #   cdyne_address_status
  # end

  def cdyne_address_status(status_code=cdyne_address_response["ReturnCode"])
    Rails.logger.info "Response code is #{status_code}"
    case status_code
    when 2
      raise "Invalid Cdyne License specified"
    when 10, 200
      return false
    when 100
      return true
    when 103
      errors.add(:address2, I18n.t('cdyne.errors.103_address_2_missing'))
      return false
    end
  end

  def cdyne_address_response
    @request ||= HTTParty.post('http://pav3.cdyne.com/PavService.svc/VerifyAddressAdvanced',
                                :body => cdyne_query_hash,
                                :headers => {"content-type" => "application/json"})
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
