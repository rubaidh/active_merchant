module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Barclaycard
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          include PostsData

          def initialize(order, account, options = {})
            super

            add_field('chargetype', 'Auth')
            add_field('password', options[:password])
            add_field('mandatecsc', (options[:mandate_csc] == false) ? "2" : "1")

            add_field('epdqdata', encrypt_transaction_details)
          end

          # Need to format the amount to have 2 decimal places
          def amount=(money)
            cents = money.respond_to?(:cents) ? money.cents : money
            if money.is_a?(String) or cents.to_i <= 0
              raise ArgumentError, 'money amount must be either a Money object or a positive integer in cents.'
            end
            add_field mappings[:amount], sprintf("%.2f", cents.to_f / 100)
          end

          mapping :account, 'clientid'
          mapping :amount, 'total'
          mapping :currency, 'currencycode'

          mapping :order, 'oid'

          mapping :customer, :first_name => '',
                             :last_name  => '',
                             :email      => 'email',
                             :phone      => 'btelephonenumber'

          mapping :billing_address, :city     => 'bcity',
                                    :address1 => 'baddr1',
                                    :address2 => 'baddr2',
                                    :address3 => 'baddr3',
                                    :state    => 'bcountyprovince',
                                    :zip      => 'bpostalcode',
                                    :country  => 'bcountry'

          mapping :shipping_address, :city     => 'scity',
                                     :address1 => 'saddr1',
                                     :address2 => 'saddr2',
                                     :address3 => 'saddr3',
                                     :state    => 'scountyprovince',
                                     :zip      => 'spostalcode',
                                     :country  => 'scountry'

          # Note: Configured in the CPI Admin Tool
          # mapping :notify_url, ''

          mapping :return_url, 'returnurl'
          mapping :cancel_return_url, ''
          mapping :description, ''
          mapping :tax, 'tax'
          mapping :shipping, 'shipping'
          mapping :collect_delivery_address , 'collectdeliveryaddress'

          # Extra special mappings
          mapping :merchant_display_name, 'merchantdisplayname'
          mapping :epdq_data, 'epdqdata'

          private
          def encrypt_transaction_details
            result = ssl_post(Barclaycard.encryption_url, {
              :total        => form_fields.delete('total'),
              :oid          => form_fields.delete('oid'),
              :chargetype   => form_fields.delete('chargetype'),
              :password     => form_fields.delete('password'),
              :currencycode => form_fields.delete('currencycode'),
              :clientid     => form_fields.delete('clientid'),
              :mandatecsc   => form_fields.delete('mandatecsc')
            }.collect { |key, value| "#{key}=#{CGI.escape(value.to_s)}" }.join("&"))

            # result now contains, somewhere, <input name=epdqdata type=hidden value="...">
            # We want the value of the 'value' attribute and to ignore the rest...
            # FIXME: Fragile!
            /value="([^"]+)"/mi.match(result)[1]
          end
        end
      end
    end
  end
end
