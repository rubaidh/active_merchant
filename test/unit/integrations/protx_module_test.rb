require File.dirname(__FILE__) + '/../../test_helper'

class ProtxModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def test_notification_method
    assert_instance_of Protx::Notification, Protx.notification('name=cody')
  end

  def test_simulator_mode
    ActiveMerchant::Billing::Base.integration_mode = :simulator
    assert_equal 'https://ukvpstest.protx.com/VSPSimulator/VSPFormGateway.asp', Protx.service_url
  end

  def test_test_mode
    ActiveMerchant::Billing::Base.integration_mode = :test
    assert_equal 'https://ukvpstest.protx.com/vspgateway/service/vspform-register.vsp', Protx.service_url
  end

  def test_production_mode
    ActiveMerchant::Billing::Base.integration_mode = :production
    assert_equal 'https://ukvps.protx.com/vspgateway/service/vspform-register.vsp', Protx.service_url
  end

  def test_invalid_mode
    ActiveMerchant::Billing::Base.integration_mode = :zoomin
    assert_raise(StandardError){ Protx.service_url }
  end
end 
