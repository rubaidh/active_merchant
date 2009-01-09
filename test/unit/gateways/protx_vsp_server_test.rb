require File.dirname(__FILE__) + '/../../test_helper'

class ProtxVspServerTest < Test::Unit::TestCase
  def setup
    @gateway = ProtxVspServerGateway.new(
      :login => 'X',
      :notification_url => 'http://test.host/notification'
    )

    @credit_card = nil
    @options = { 
      :billing_address => {
        :address1 => '25 The Larches',
        :city => "Narborough",
        :state => "Leicester",
        :zip => 'LE10 2RT'
      },
      :order_id => '1',
      :description => 'Store purchase'
    }
    @amount = 100
  end

  def test_successful_purchase
    @gateway.expects(:ssl_post).returns(successful_purchase_response)

    assert response = @gateway.purchase(@amount, @options)
    assert_instance_of ProtxVspServerResponse, response
    assert_equal "1;{7307C8A9-766E-4BD1-AC41-3C34BB83F7E5};;WIUMDJS607", response.authorization
    assert_success response
  end

  def test_unsuccessful_purchase
    @gateway.expects(:ssl_post).returns(unsuccessful_purchase_response)

    assert response = @gateway.purchase(@amount, @options)
    assert_instance_of ProtxVspServerResponse, response
    assert_failure response
  end

  def test_purchase_url
    assert_equal 'https://ukvpstest.protx.com/vspgateway/service/vspserver-register.vsp', @gateway.send(:url_for, :purchase)
  end

  def test_capture_url
    assert_equal 'https://ukvpstest.protx.com/vspgateway/service/release.vsp', @gateway.send(:url_for, :capture)
  end

  private
  def successful_purchase_response
    <<-RESP
VPSProtocol=2.22
Status=OK
StatusDetail=VSP Server transaction registered successfully.
VPSTxId={7307C8A9-766E-4BD1-AC41-3C34BB83F7E5}
SecurityKey=WIUMDJS607
NextURL=https://ukvpstest.protx.com/VSPSimulator/VSPServerPaymentPage.asp?TransactionID={7307C8A9-766E-4BD1-AC41-3C34BB83F7E5}
    RESP
  end

  def unsuccessful_purchase_response
    <<-RESP
VPSProtocol=2.22
Status=ERROR
StatusDetail=OMGWTFLOL!
    RESP
  end
end
