# frozen_string_literal: true

require "spid/logout_request"
require "onelogin/ruby-saml/settings"

module Spid
  module Slo
    class Request # :nodoc:
      attr_reader :idp_name
      attr_reader :session_index
      attr_reader :relay_state

      def initialize(idp_name:, session_index:, relay_state: nil)
        @idp_name = idp_name
        @session_index = session_index
        @relay_state =
          begin
            relay_state || Spid.configuration.default_relay_state_path
          end
      end

      def url
        logout_request.create(
          saml_settings,
          "RelayState" => relay_state
        )
      end

      def saml_settings
        slo_settings.saml_settings
      end

      def slo_settings
        Settings.new(
          service_provider: service_provider,
          identity_provider: identity_provider,
          session_index: session_index
        )
      end

      def identity_provider
        @identity_provider ||=
          IdentityProviderManager.find_by_name(idp_name)
      end

      def service_provider
        @service_provider ||=
          Spid.configuration.service_provider
      end

      private

      def logout_request
        LogoutRequest.new
      end
    end
  end
end
