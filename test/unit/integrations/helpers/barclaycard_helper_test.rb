require File.dirname(__FILE__) + '/../../../test_helper'

class BarclaycardHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    Barclaycard::Helper.any_instance.stubs(:ssl_post).returns("<input value=\"encrypted-data\">")

    @helper = Barclaycard::Helper.new('order-500','1411', :amount => 500, :currency => 'GBP', :password => 'foobar')
  end

  # Fields which are encrypted are removed from the final form.  Despite being
  # supplied above, they should be nil now.
  def test_encrypted_fields
    assert_field 'clientid', nil
    assert_field 'total', nil
    assert_field 'oid', nil
    assert_field 'currencycode', nil
    assert_field 'mandatecsc', nil
    assert_field 'password', nil
    assert_field 'chargetype', nil
  end

  def test_encryption
    assert_field 'epdqdata', 'encrypted-data'
  end

  def test_customer_fields
    @helper.customer :first_name => 'Cody', :last_name => 'Fauser', :email => 'cody@example.com'
    assert_field 'email', 'cody@example.com'
  end

  def test_billing_address_mapping
    @helper.billing_address :address1 => '1 My Street',
                            :address2 => '',
                            :city => 'Leeds',
                            :state => 'Yorkshire',
                            :zip => 'LS2 7EE',
                            :country  => 'CA'

    assert_field 'baddr1', '1 My Street'
    assert_field 'baddr2', nil
    assert_field 'bcity', 'Leeds'
    assert_field 'bcountyprovince', 'Yorkshire'
    assert_field 'bpostalcode', 'LS2 7EE'
    assert_field 'bcountry', 'CA'
  end

  def test_shipping_address_mapping
    @helper.shipping_address :address1 => '1 My Street',
                             :address2 => '',
                             :city => 'Leeds',
                             :state => 'Yorkshire',
                             :zip => 'LS2 7EE',
                             :country  => 'CA'

    assert_field 'saddr1', '1 My Street'
    assert_field 'saddr2', nil
    assert_field 'scity', 'Leeds'
    assert_field 'scountyprovince', 'Yorkshire'
    assert_field 'spostalcode', 'LS2 7EE'
    assert_field 'scountry', 'CA'
  end

  def test_unknown_address_mapping
    existing_fields = @helper.fields.size

    @helper.billing_address :farm => 'CA'

    assert_equal existing_fields, @helper.fields.size
  end

  def test_unknown_mapping
    assert_nothing_raised do
      @helper.company_address :address => '500 Dwemthy Fox Road'
    end
  end

  def test_setting_invalid_address_field
    fields = @helper.fields.dup
    @helper.billing_address :street => 'My Street'
    assert_equal fields, @helper.fields
  end
end
