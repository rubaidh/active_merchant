module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Protx
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          extend Common::ClassMethods
          include Common::InstanceMethods
          include ActionView::Helpers::NumberHelper

          def initialize(order, account, options = {})
            # We need to extract extra options before super is called because
            # it asserts that only particular options were passed in...
            self.key = options.delete(:key)
            super
            add_field('VPSProtocol', '2.22')
            add_field('TxType', 'PAYMENT')
          end

          # Vendor login name.  Used to authenticate your site.  This
          # should contain the VSP Vendor Name supplied by Protx when
          # your account was created.
          mapping :account, 'Vendor'
          
          # Vendor transaction code.  This should be your own reference code
          # to the transaction.  Your site should provide a comletely unique
          # VendorTxCode for each transaction.
          mapping :order, 'VendorTxCode'

          # Amount for the Transaction containing minor digits formatted to 2
          # decimal places where appropriate.  Must be positive and numeric,
          # and may include a decimal place where appropriate.  Minor digits
          # should be formatted to two decimal places e.g. 5.10 or 3.29. 
          # Values such as 3.235 will be rejected.
          mapping :amount, 'Amount'

          # Three-letter currency code to ISO 4217. Examples: "GBP", "EUR" and
          # "USD".  The currency must be supported by one of your VSP merchant
          # accounts or the transaction will be rejected. 
          mapping :currency, 'Currency'

          mapping :notify_url, 'SuccessURL'
          mapping :return_url, 'FailureURL'

          mapping :customer, :name => 'CustomerName',
            :email => 'CustomerEmail',
            :phone => 'ContactNumber',
            :fax   => 'ContactFax'
          
          mapping :description, 'Description'

          mapping :message, 'EmailMessage'
          
          mapping :vendor_email, 'VendorEmail'

          mapping :billing_address, :address => 'BillingAddress', :postcode => 'BillingPostCode'
          mapping :shipping_address, :address => 'DeliveryAddress', :postcode => 'DeliveryPostCode'

          mapping :basket, 'Basket'
          
          mapping :allow_gift_aid, 'AllowGiftAid'
          mapping :apply_avs_cv2, 'ApplyAVSCV2'
          mapping :apply_3d_secure, 'Apply3DSecure'

          # Override the default implementation of +form_fields+ because we
          # want to encode most of the fields and stick them in the +Crypt+
          # parameter instead.
          def form_fields
            # Return URL defaults to the same as the notify URL because
            # they're both supplied with the same information anyway.
            add_field(mappings[:return_url], fields[mappings[:notify_url]]) if fields[mappings[:return_url]].nil?
            fields = @fields.dup
            {
              "VPSProtocol" => fields.delete("VPSProtocol"),
              "TxType"      => fields.delete("TxType"),
              "Vendor"      => fields.delete("Vendor"),
              "Crypt"       => encrypt(fields)
            }
          end

          # Format the amount correctly as Protx desires.
          def amount=(value)
            add_field(mappings[:amount], sprintf("%.2f", value))
          end
          alias_method :amount, :amount=

          # Preserve the existing behaviour of having first name & last
          # name passed in, while Protx takes it as one.
          def customer=(params)
            add_field(mappings[:customer][:name], params[:name] || [params[:first_name], params[:last_name]].compact.join(" "))
            add_field(mappings[:customer][:email], self.class.format_email_addresses(params[:email]))
            add_field(mappings[:customer][:phone], params[:phone])
            add_field(mappings[:customer][:fax],   params[:fax])
          end
          alias_method :customer, :customer=

          def vendor_email=(email)
            add_field(mappings[:vendor_email], self.class.format_email_addresses(email))
          end
          alias_method :vendor_email, :vendor_email=

          def billing_address=(params)
            add_field(mappings[:billing_address][:address],
              [
                params[:address1],
                params[:address2],
                params[:city],
                params[:state],
                params[:country]
              ].compact.join("\n")
            )
            add_field(mappings[:billing_address][:postcode], params[:zip])
          end
          alias_method :billing_address, :billing_address=

          def shipping_address=(params)
            add_field(mappings[:shipping_address][:address],
              [
                params[:address1],
                params[:address2],
                params[:city],
                params[:state],
                params[:country]
              ].compact.join("\n")
            )
            add_field(mappings[:shipping_address][:postcode], params[:zip])
          end
          alias_method :shipping_address, :shipping_address=
          
          # The shopping basket as it is shown in the Protx system.  The
          # parameter, +items+, is an array of hashes.  Each hash contains
          # as many of the following items as you want to fill in:
          # 
          # +description+ The description of the item.
          # +quantity+ The number of those items ordered.
          # +item_value+ The net value of the item.
          # +item_tax+ The taxable value of the item.
          # +item_total+ The total value of the item (ie net + tax).
          # +line_total+ The total value of the line (item_total * quantity, probably).
          def basket=(items)
            add_field(mappings[:basket], format_as_basket(items))
          end
          alias_method :basket, :basket=
          
          private
          def format_as_basket(items)
            [
              items.length,
              items.map { |item| 
                [
                  escape_basket_item(item[:description].to_s),
                  escape_basket_item(item[:quantity].to_s),
                  escape_basket_item(number_to_currency(item[:item_value]).to_s),
                  escape_basket_item(number_to_currency(item[:item_tax]).to_s),
                  escape_basket_item(number_to_currency(item[:item_total]).to_s),
                  escape_basket_item(number_to_currency(item[:line_total]).to_s)
                ]
              }
            ].flatten.join(":")
          end
          
          # The documentation doesn't actually make it clear how to escape
          # colons in the basket string, but to be on the safe side, we
          # should escape them as something...  I'm switching them for
          # a ' - ' dash instead.
          def escape_basket_item(str)
            str.gsub /:/, ' - '
          end
        end
      end
    end
  end
end
