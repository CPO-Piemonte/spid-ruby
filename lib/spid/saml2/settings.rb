# frozen_string_literal: true

require "base64"

module Spid
  module Saml2
    class Settings # :nodoc:
      attr_reader :identity_provider
      attr_reader :service_provider
      attr_reader :authn_context

      def initialize(identity_provider:, service_provider:, authn_context: nil)
        @authn_context = authn_context || Spid::L1
        unless AUTHN_CONTEXTS.include?(@authn_context)
          raise Spid::UnknownAuthnContextError,
                "Provided authn_context '#{@authn_context}' is not valid:" \
                " use one of #{AUTHN_CONTEXTS.join(', ')}"
        end

        @identity_provider = identity_provider
        @service_provider = service_provider
      end

      def idp_entity_id
        identity_provider.entity_id
      end

      def idp_sso_target_url
        identity_provider.sso_target_url
      end

      def idp_slo_target_url
        identity_provider.slo_target_url
      end

      def sp_entity_id
        service_provider.host
      end

      def private_key
        service_provider.private_key
      end

      def certificate
        service_provider.certificate
      end

      def signature_method
        service_provider.signature_method
      end

      def acs_index
        "0"
      end

      def force_authn?
        authn_context > Spid::L1
      end

      def x509_certificate_der
        @x509_certificate_der ||=
          begin
            cert = OpenSSL::X509::Certificate.new(certificate)
            Base64.encode64(cert.to_der).delete("\n")
          end
      end
    end
  end
end
