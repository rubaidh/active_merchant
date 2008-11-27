module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Protx
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          extend Common::ClassMethods
          include Common::InstanceMethods

          # Was the order successfully completed?
          def complete?
            status_in? :ok
          end

          # Did the order fail because the user's card details were not
          # valid or the card was declined by the bank?
          def failed?
            status_in? :notauthed, :rejected
          end

          # Did the user cancel the transaction?
          def cancelled?
            status_in? :abort
          end
          
          # Was there some sort of error with either us or Protx?
          def error?
            status_in? :malformed, :invalid, :error
          end

          # For a 'authenticate' TxType, was it successfully authenticated?
          def authenticated?
            status_in? :authenticated, :registered
          end

          # Possible values:
          #                
          # :ok – Transaction completed successfully with authorisation. 
          #                
          # :notauthed – The VSP system  could not authorise the transaction
          # because the details provided by the Customer were incorrect, or
          # not authenticated by the acquiring bank. 
          #                
          # :malformed – Input message was missing fields or badly formatted
          # – normally will only occur during development and vendor
          # integration.  
          #                
          # :invalid – Transaction was not registered because although the
          # POST format was valid, some information supplied was invalid. E.g.
          # incorrect vendor name or currency. 
          #                
          # :abort – The Transaction could not be completed because the user
          # clicked the CANCEL button on the payment pages, or went inactive
          # for 15 minutes or longer. 
          #                
          # :rejected – The VSP System rejected the transaction because of
          # the fraud screening rules you have set on your account. 
          #                
          # :authenticated – The 3D- Secure checks were performed
          # successfully and the card details secured at Protx. 
          #                
          # :registered – 3D-Secure checks failed or were not performed, but
          # the card details are still secured at Protx. 
          #                
          # :error – A problem occurred at Protx which prevented transaction
          # completion.
          #         
          # In the case of :notauthed, the Transaction has completed through
          # the VSP System, but it has not been authorised by the bank. 
          #                
          # A status of :rejected means the bank may have authorised the
          # transaction but your own rule bases for AVS/CV2 or 3D- Secure
          # caused the transaction to be rejected. 
          #                
          # In the cases of :abort, :malformed, :invalid and :error (see
          # below) the Transaction has not completed through the VSP and can
          # be retried. 
          #                
          # :authenticated and :registered statuses are only returned if the
          # TxType is :authenticate.
          #   
          # Please notify Protx if a Status report of ERROR is seen, together
          # with your VendorTxCode and the StatusDetail text. 
          def status
            params['Status'].downcase.to_sym
          end

          # Human-readable text providing extra detail for the Status message.
          # You should always check this value if the Status is not OK.
          def status_detail
            params['StatusDetail']
          end

          # Your unique Vendor Transaction Code. Same as sent by your servers
          # in Step A1. 
          def order
            params['VendorTxCode']
          end

          # The Protx ID to uniquely identify the Transaction on our system.
          # Only present if Status not :invalid, :malformed or :error.
          def transaction_id
            error? ? nil : params['VPSTxId']
          end

          # Protx unique Authorisation Code for a successfully authorised
          # transaction. Only present if Status is :ok. 
          def auth_code
            complete? ? params['TxAuthNo'].to_i : nil
          end

          # The total value of the transaction. Should match that sent in A1. 
          # Included to allow non-database driven users to react to the total
          # order value. 
          def gross
            params['Amount'].to_f
          end

          def gross_cents
            (gross.to_f * 100.0).round
          end

          # Possible values are :notprovided, :notchecked, :matched, &
          # :notmatched. The specific result of the checks on the
          # cardholder’s address numeric from the AVS/CV2 checks.  Not
          # present if the Status is :authenticated or :registered.
          # 
          # In fact, in practice it only seems to be present if the status
          # is ok, which is why we're checking on +complete?+ instead.
          def address_result
            complete? ? params['AddressResult'].downcase.to_sym : nil
          end

          # Possible values are :notprovided, :notchecked, :matched, &
          # :notmatched. The specific result of the checks on the
          # cardholder’s post code from the AVS/CV2 checks.  Not present if
          # the Status is :authenticated or :registered.
          # 
          # In fact, in practice it only seems to be present if the status
          # is ok, which is why we're checking on +complete?+ instead.
          def postcode_result
            complete? ? params['PostCodeResult'].downcase.to_sym : nil
          end

          # Possible values are :notprovided, :notchecked, :matched, &
          # :notmatched. The specific result of the checks on the
          # cardholder’s CV2 code from the AVS/CV2 checks.  Not present if
          # the Status is :authenticated or :registered.
          # 
          # In fact, in practice it only seems to be present if the status
          # is ok, which is why we're checking on +complete?+ instead.
          def cv2_result
            complete? ? params['CV2Result'].downcase.to_sym : nil
          end

          def gift_aid?
            params['GiftAid'].to_i == 1
          end

          # :ok - 3D Secure checks carried out and user authenticated
          # correctly. 
          #  
          # :notchecked – 3D-Secure checks were not performed. 
          #  
          # :notavailable – The card used was either not part of the 3D
          # Secure Scheme, or the authorisation was not possible.
          #  
          # :notauthed – 3D-Secure authentication checked, but the user
          # failed the authentication.
          #  
          # :incomplete – 3D-Secure authentication was unable to complete. 
          # No authentication occurred. 
          #  
          # :error - Authentication could not be attempted due to data errors
          # or service unavailability in one of the parties involved in the
          # check. This field details the results of the 3D-Secure checks
          # (where appropriate).
          #  
          # :notchecked indicates that 3D-Secure was either switched off at an
          # account level, or disabled at transaction registration with a
          # setting like Apply3DSecure=2 
          # 
          # In fact, in practice it only seems to be present if the status
          # is ok, which is why we're checking on +complete?+ instead.
          def threed_secure_status
            complete? ? params['3DSecureStatus'].downcase.to_sym : nil
          end

          def threed_secure_status_ok?
            threed_secure_status == :ok
          end
          # The encoded result code from the 3D-Secure checks (CAVV or UCAF).
          # Only present if the 3DSecureStatus field is :ok.
          def cavv
            threed_secure_status_ok? ? params['CAVV'] : nil
          end

          private
          def parse(post)
            super
            self.key = @options[:key]
            
            # OK, here's one that took me a couple of hours to track down.
            # Protx have chosen to use a Base64-encoded string to convey
            # their results.  Unfortunately, the '+' symbol is a valid
            # Base64 character and it also has a special significance in
            # the world of query strings (representing a space).  So once
            # we have parsed out the query string, we have changed all the
            # '+' signs into spaces.  This is not what the Base64 decoder
            # wants to see, so we have to shift it back.  Argh.
            @params = decrypt(@params['crypt'].gsub(/ /, '+'))
          end
          
          def status_in?(*args)
            args.include?(status)
          end
        end
      end
    end
  end
end
