# frozen_string_literal: true

module Spid
  class Rack
    class Sso # :nodoc:
      attr_reader :app

      def initialize(app)
        @app = app
      end

      def call(env)
        @sso = SsoEnv.new(env)

        if @sso.valid_request?
          @sso.response
        else
          app.call(env)
        end
      end

      class SsoEnv # :nodoc:
        attr_reader :env
        attr_reader :request

        def initialize(env)
          @env = env
          @request = ::Rack::Request.new(env)
        end

        def store_session
          request.session["spid"] = {
            "attributes" => sso_response.attributes,
            "session_index" => sso_response.session_index
          }
        end

        def response
          store_session
          [
            302,
            { "Location" => relay_state },
            []
          ]
        end

        def saml_response
          request.params["SAMLResponse"]
        end

        def relay_state
          if !request.params["RelayState"].nil? &&
             request.params["RelayState"] != ""
            request.params["RelayState"]
          else
            Spid.configuration.default_relay_state_path
          end
        end

        def valid_get?
          request.get? &&
            Spid.configuration.acs_binding == Spid::BINDINGS_HTTP_REDIRECT
        end

        def valid_post?
          request.post? &&
            Spid.configuration.acs_binding == Spid::BINDINGS_HTTP_POST
        end

        def valid_http_verb?
          valid_get? || valid_post?
        end

        def valid_path?
          request.path == Spid.configuration.acs_path
        end

        def valid_request?
          valid_path? && valid_http_verb?
        end

        def sso_response
          ::Spid::Sso::Response.new(body: saml_response)
        end
      end
    end
  end
end
