require File.dirname(__FILE__) + '/../../test_helper'

class ProtxVspServerModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def test_service_urls
    ActiveMerchant::Billing::Base.integration_mode = :production
    assert_equal 'https://ukvps.protx.com/vspgateway/service/vspserver-register.vsp', ProtxVspServer.service_url

    ActiveMerchant::Billing::Base.integration_mode = :test
    assert_equal 'https://ukvpstest.protx.com/vspgateway/service/vspserver-register.vsp', ProtxVspServer.service_url

    ActiveMerchant::Billing::Base.integration_mode = :simulator
    assert_equal 'https://ukvpstest.protx.com/VSPSimulator/VSPServerGateway.asp', ProtxVspServer.service_url
  end

  def test_notification_method
    assert_instance_of ProtxVspServer::Notification, ProtxVspServer.notification('name=mathie')
  end

  def test_return_method
    assert_instance_of ProtxVspServer::Return, ProtxVspServer.return('name=mathie')
  end
end 
