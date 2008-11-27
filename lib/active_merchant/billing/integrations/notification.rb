module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      class Notification
        attr_accessor :params
        attr_accessor :raw
        
        # set this to an array in the subclass, to specify which IPs are allowed to send requests
        class_inheritable_accessor :production_ips

        def initialize(post, options = {})
          @options = options
          empty!
          parse(post)
        end

        def status
          params['Status']
        end

        def status_detail
          params['StatusDetail']
        end

        # The id the helper passed in to identify the order.
        def order
          params['VPSTxId']
        end

        # the money amount we received in X.2 decimal.
        def gross
          params['Amount'].to_f
        end

        def gift_aid?
          params['GiftAid'].to_i > 0
        end

        def gross_cents
          (gross.to_f * 100.0).round
        end

        def cv2_result
          params['CV2Result'].downcase.to_sym
        end

        
        # This combines the gross and currency and returns a proper Money object. 
        # this requires the money library located at http://dist.leetsoft.com/api/money
        def amount
          return Money.new(gross_cents, currency) rescue ArgumentError
          return Money.new(gross_cents) # maybe you have an own money object which doesn't take a currency?
        end

        # reset the notification. 
        def empty!
          @params  = Hash.new
          @raw     = ""      
        end
        
        # Check if the request comes from an official IP
        def valid_sender?(ip)
          return true if ActiveMerchant::Billing::Base.integration_mode == :test || production_ips.blank?
          production_ips.include?(ip)
        end
        
        private

        # Take the posted data and move the relevant data into a hash
        def parse(post)
          @raw = post.to_s
          for line in @raw.split('&')    
            key, value = *line.scan( %r{^([A-Za-z0-9_.]+)\=(.*)$} ).flatten
            params[key] = CGI.unescape(value)
          end
        end
      end
    end
  end
end
