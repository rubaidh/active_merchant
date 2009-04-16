require File.dirname(__FILE__) + '/../../../test_helper'

class BarclaycardNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @barclaycard = Barclaycard::Notification.new(http_raw_data)
  end

  def test_accessors
    assert @barclaycard.complete?
    assert_equal "", @barclaycard.status
    assert_equal "", @barclaycard.transaction_id
    assert_equal "", @barclaycard.item_id
    assert_equal "", @barclaycard.gross
    assert_equal "", @barclaycard.currency
    assert_equal "", @barclaycard.received_at
    assert @barclaycard.test?
  end

  def test_compositions
    assert_equal Money.new(3166, 'USD'), @barclaycard.amount
  end

  # Replace with real successful acknowledgement code
  def test_acknowledgement    

  end

  def test_send_acknowledgement
  end

  def test_respond_to_acknowledge
    assert @barclaycard.respond_to?(:acknowledge)
  end

  private
  def http_raw_data
    ""
  end  
end
