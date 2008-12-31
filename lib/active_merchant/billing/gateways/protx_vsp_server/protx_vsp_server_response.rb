module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class ProtxVspServerResponse < Response
      def next_url
        @params['NextURL']
      end

      def transaction_id
        @params['VPSTxId']
      end

      def security_key
        @params['SecurityKey']
      end
    end
  end
end