require File.dirname(__FILE__) + '/../test_helper'

class RemoteProtxIntegrationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def test_correct_service_url
    assert_equal "https://ukvpstest.protx.com/vspgateway/service/vspform-register.vsp", Protx.service_url
    @protx = Protx::Notification.new('')
    
    assert_nothing_raised do
      assert_equal false, @protx.acknowledge  
    end
  end
end
