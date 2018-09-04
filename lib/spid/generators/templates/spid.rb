# frozen_string_literal: true

Spid.configure do |config|
  config.hostname = ENV.fetch("HOST")

  config.idp_metadata_dir_path = Rails.root.join("config/idp_metadata")
  config.private_key_path = Rails.root.join("config/spid-private-key.pem")
  config.certificate_path = Rails.root.join("config/spid-certificate.pem")

  config.metadata_path  = "/spid/metadata"
  config.start_sso_path = "/spid/login"
  config.start_slo_path = "/spid/logout"
  config.acs_path = "/spid/sso"
  config.slo_path = "/spid/slo"
  config.default_relay_state_path = "/"

  config.digest_method = Spid::SHA512
  config.signature_method = Spid::RSA_SHA512
  config.acs_binding = Spid::BINDINGS_HTTP_POST
  config.slo_binding = Spid::BINDINGS_HTTP_REDIRECT
  config.attribute_services = [
    { name: "Service1", fields: ["email"] }
  ]
end
