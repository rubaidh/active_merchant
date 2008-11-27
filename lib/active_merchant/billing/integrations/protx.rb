require "#{File.dirname(__FILE__)}/protx/common.rb"
require "#{File.dirname(__FILE__)}/protx/helper.rb"
require "#{File.dirname(__FILE__)}/protx/notification.rb"

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Protx
        
        # Overwrite this if you want to change the Protx simulator url
        mattr_accessor :simulator_service_url
        self.simulator_service_url = 'https://ukvpstest.protx.com/VSPSimulator/VSPFormGateway.asp'
        
        # Overwrite this if you want to change the Protx test url
        mattr_accessor :test_service_url
        self.test_service_url = 'https://ukvpstest.protx.com/vspgateway/service/vspform-register.vsp'
        
        # Overwrite this if you want to change the Protx production url
        mattr_accessor :production_service_url 
        self.production_service_url = 'https://ukvps.protx.com/vspgateway/service/vspform-register.vsp' 
        
        def self.service_url
          mode = ActiveMerchant::Billing::Base.integration_mode
          case mode
          when :production
            self.production_service_url    
          when :test
            self.test_service_url
          when :simulator
            self.simulator_service_url
          else
            raise StandardError, "Integration mode set to an invalid value: #{mode}"
          end
        end

        mattr_accessor :simulator_admin_url
        self.simulator_admin_url = 'https://ukvpstest.protx.com/VSPSimulator/'

        mattr_accessor :test_admin_url
        self.test_admin_url = 'https://ukvpstest.protx.com/vspadmin/'

        mattr_accessor :production_admin_url
        self.production_admin_url = 'https://ukvps.protx.com/vspadmin/'

        def self.admin_url
          mode = ActiveMerchant::Billing::Base.integration_mode
          case mode
          when :production
            self.production_admin_url    
          when :test
            self.test_admin_url
          when :simulator
            self.simulator_admin_url
          else
            raise StandardError, "Integration mode set to an invalid value: #{mode}"
          end
        end

        def self.notification(post)
          Notification.new(post)
        end
      end
    end
  end
end
