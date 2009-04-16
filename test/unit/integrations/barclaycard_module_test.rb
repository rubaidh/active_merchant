require File.dirname(__FILE__) + '/../../test_helper'

class BarclaycardModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def test_notification_method
    assert_instance_of Barclaycard::Notification, Barclaycard.notification('name=cody')
  end
end 
