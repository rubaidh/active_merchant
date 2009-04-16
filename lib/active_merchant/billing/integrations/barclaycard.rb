require File.dirname(__FILE__) + '/barclaycard/helper.rb'
require File.dirname(__FILE__) + '/barclaycard/notification.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Barclaycard 

        mattr_accessor :test_encryption_url, :production_encryption_url
        self.test_encryption_url = 'https://secure2.mde.epdq.co.uk/cgi-bin/CcxBarclaysEpdqEncTool.e'
        self.production_encryption_url = 'https://secure2.epdq.co.uk/cgi-bin/CcxBarclaysEpdqEncTool.e'

        mattr_accessor :test_service_url, :production_service_url
        self.test_service_url = 'https://secure2.mde.epdq.co.uk/cgi-bin/CcxBarclaysEpdq.e'
        self.production_service_url = 'https://secure2.epdq.co.uk/cgi-bin/CcxBarclaysEpdq.e'

        def self.encryption_url
          case ActiveMerchant::Billing::Base.integration_mode
          when :production
            self.production_encryption_url
          when :test
            self.test_encryption_url
          else
            raise StandardError, "Integration mode set to an invalid value: #{ActiveMerchant::Billing::Base.integration_mode}"
          end
        end

        def self.service_url
          case ActiveMerchant::Billing::Base.integration_mode
          when :production
            self.production_service_url
          when :test
            self.test_service_url
          else
            raise StandardError, "Integration mode set to an invalid value: #{ActiveMerchant::Billing::Base.integration_mode}"
          end
        end

        def self.notification(post)
          Notification.new(post)
        end  
      end
    end
  end
end
