require 'net/http'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Barclaycard
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          def complete?
            status == 'Success'
          end 

          def status
            params['transactionstatus']
          end

          # the money amount we received in X.2 decimal.
          def gross
            params['total']
          end

          def account
            params['clientid']
          end

          def transaction_id
            params['oid']
          end

          def charge_type
            params['chargetype']
          end

          # When was this payment received by the client.
          def received_at
            Time.strptime(params['datetime'], "%b %d %Y %H:%M:%S")
          end

          def eci_status
            params['ecistatus']
          end

          def card_prefix
            params['cardprefix']
          end
        end
      end
    end
  end
end
