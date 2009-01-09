require File.dirname(__FILE__) + '/protx_vsp_server/helper.rb'
require File.dirname(__FILE__) + '/protx_vsp_server/notification.rb'
require File.dirname(__FILE__) + '/protx_vsp_server/return.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module ProtxVspServer 
       
        mattr_accessor :production_service_url
        self.production_service_url = 'https://ukvps.protx.com/vspgateway/service/vspserver-register.vsp'

        mattr_accessor :test_service_url
        self.test_service_url = 'https://ukvpstest.protx.com/vspgateway/service/vspserver-register.vsp'

        mattr_accessor :simulator_service_url
        self.simulator_service_url = 'https://ukvpstest.protx.com/VSPSimulator/VSPServerGateway.asp'

        def self.service_url
          case ActiveMerchant::Billing::Base.integration_mode
          when :production
            self.production_service_url
          when :test
            self.test_service_url
          when :simulator
            self.simulator_service_url
          end
        end

        def self.notification(post)
          Notification.new(post)
        end

        def self.return(query_string)
          Return.new(query_string)
        end
      end
    end
  end
end
