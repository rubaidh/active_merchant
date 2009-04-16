require File.dirname(__FILE__) + '/../../test_helper'

class BarclaycardModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def test_notification_method
    assert_instance_of Barclaycard::Notification, Barclaycard.notification('name=cody')
  end

  def test_test_mode
    ActiveMerchant::Billing::Base.integration_mode = :test
    assert_equal 'https://secure2.mde.epdq.co.uk/cgi-bin/CcxBarclaysEpdq.e', Barclaycard.service_url
    assert_equal 'https://secure2.mde.epdq.co.uk/cgi-bin/CcxBarclaysEpdqEncTool.e', Barclaycard.encryption_url
  end

  def test_production_mode
    ActiveMerchant::Billing::Base.integration_mode = :production
    assert_equal 'https://secure2.epdq.co.uk/cgi-bin/CcxBarclaysEpdq.e', Barclaycard.service_url
    assert_equal 'https://secure2.epdq.co.uk/cgi-bin/CcxBarclaysEpdqEncTool.e', Barclaycard.encryption_url
  end

  def test_invalid_mode
    ActiveMerchant::Billing::Base.integration_mode = :zoomin
    assert_raise(StandardError){ Barclaycard.service_url }
  end
end 
