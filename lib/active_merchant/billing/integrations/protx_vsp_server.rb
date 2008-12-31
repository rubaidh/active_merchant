require File.dirname(__FILE__) + '/protx_vsp_server/helper.rb'
require File.dirname(__FILE__) + '/protx_vsp_server/notification.rb'
require File.dirname(__FILE__) + '/protx_vsp_server/return.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module ProtxVspServer 
       
        mattr_accessor :service_url
        self.service_url = 'https://www.example.com'

        def self.notification(post)
          Notification.new(post)
        end  
      end
    end
  end
end
