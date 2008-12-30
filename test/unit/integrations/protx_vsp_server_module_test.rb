require File.dirname(__FILE__) + '/../../test_helper'

class ProtxVspServerModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def test_notification_method
    assert_instance_of ProtxVspServer::Notification, ProtxVspServer.notification('name=cody')
  end
end 
