module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Protx
        module Common
          module ClassMethods
            def to_query_string(fields)
              fields.map {|key,value| "#{key}=#{value}"}.join("&")
            end

            def from_query_string(str)
              returning CGI::parse(str) do |params|
                # Flatten out the result of the CGI query string parser.
                params.each do |key,value|
                  params[key] = value.first
                end
              end
            end

            def xor(s1, s2)
              a1 = s1.unpack('C*')
              a2 = s2.unpack('C*')
              a2 *= a1.length/a2.length + 1
              a1.zip(a2).map { |c1, c2| c1^c2 }.pack("C*")
            end

            def base64_encode(str)
              Base64.encode64(str).split("\n").join
            end

            def base64_decode(str)
              Base64.decode64(str)
            end

            def format_email_addresses(emails)
              emails.respond_to?(:join) ? emails.join(':') : emails
            end
            
            def encrypt(fields, key)
              base64_encode(xor(to_query_string(fields), key))
            end
            
            def decrypt(str, key)
              from_query_string(xor(base64_decode(str), key))
            end
          end
          
          module InstanceMethods
            def self.included(base)
              base.send :attr_accessor, :key
            end

            def encrypt(fields)
              self.class.encrypt fields, key
            end

            def decrypt(str)
              self.class.decrypt str, key
            end
          end
        end
      end
    end
  end
end