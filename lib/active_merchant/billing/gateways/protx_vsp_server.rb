require File.dirname(__FILE__) + '/protx_vsp_server/protx_vsp_server_response'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class ProtxVspServerGateway < ProtxGateway
      def initialize(options = {})
        requires!(options, :notification_url)
        super
      end

      def purchase(money, options = {})
        super(money, nil, options)
      end

      def authorize(money, options = {})
        super(money, nil, options)
      end

      # VSP Server doesn't pass credit cards in during the HTTP POST, so we
      # won't be expecting any to be passed in.
      def add_credit_card(post, credit_card)
      end

      def commit(action, parameters)
        response = parse( ssl_post(url_for(action), post_data(action, parameters)) )

        ProtxVspServerResponse.new(response["Status"] == APPROVED, message_from(response), response,
          :test => test?,
          :authorization => authorization_from(response, parameters)
        )
      end

      def build_url(action)
        endpoint = [ :purchase, :authorization ].include?(action) ? "vspserver-register" : TRANSACTIONS[action].downcase
        "#{test? ? TEST_URL : LIVE_URL}/#{endpoint}.vsp"
      end
      
      def build_simulator_url(action)
        endpoint = "VSPServerGateway.asp?Service=VendorRegisterTx"
        "#{SIMULATOR_URL}/#{endpoint}"
      end

      def post_data(action, parameters = {})
        parameters.update(
          :NotificationURL => @options[:notification_url]
        )
        super
      end
    end
  end
end

