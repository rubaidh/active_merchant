require File.dirname(__FILE__) + '/../../../test_helper'

class ProtxVspServerNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @protx_vsp_server = ProtxVspServer::Notification.new(http_raw_data)
  end

  def test_accessors
    assert @protx_vsp_server.complete?
    assert_equal "", @protx_vsp_server.status
    assert_equal "", @protx_vsp_server.transaction_id
    assert_equal "", @protx_vsp_server.item_id
    assert_equal "", @protx_vsp_server.gross
    assert_equal "", @protx_vsp_server.currency
    assert_equal "", @protx_vsp_server.received_at
    assert @protx_vsp_server.test?
  end

  def test_compositions
    assert_equal Money.new(3166, 'USD'), @protx_vsp_server.amount
  end

  # Replace with real successful acknowledgement code
  def test_acknowledgement    

  end

  def test_send_acknowledgement
  end

  def test_respond_to_acknowledge
    assert @protx_vsp_server.respond_to?(:acknowledge)
  end

  private
  def http_raw_data
    ""
  end  
end
