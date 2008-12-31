require 'net/http'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module ProtxVspServer
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          def initialize(post, options = {})
            @received_at = Time.now
            super
          end

          def complete?
            status == 'OK'
          end 

          def item_id
            params['VendorTxCode']
          end

          def transaction_id
            params['VPSTxId']
          end

          # When was this payment received by the client. 
          def received_at
            @received_at
          end

          def security_key
            params['TxAuthNo']
          end

          # the money amount we received in X.2 decimal.
          def gross
            params['Amount'].to_f
          end

          # FIXME: How do we know if this was a test transaction?
          def test?
            params[''] == 'test'
          end

          def status
            params['Status']
          end

          def acknowledge
            true
          end
 private

          # Take the posted data and move the relevant data into a hash
          def parse(post)
            @raw = post
            for line in post.split('&')
              key, value = *line.scan( %r{^(\w+)\=(.*)$} ).flatten
              params[key] = value
            end
          end
        end
      end
    end
  end
end
