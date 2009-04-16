require File.dirname(__FILE__) + '/barclaycard/helper.rb'
require File.dirname(__FILE__) + '/barclaycard/notification.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Barclaycard 
       
        mattr_accessor :service_url
        self.service_url = 'https://www.example.com'

        def self.notification(post)
          Notification.new(post)
        end  
      end
    end
  end
end
