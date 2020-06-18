require 'omniauth_openid_connect'

module OmniAuth
  module Strategies
    class FranceConnect < OpenIDConnect
      option :client_auth_method, "Custom"
      option :client_signing_alg, :HS256
      # option :state, -> { SecureRandom.hex(32) }

      option :client_options, {
        port: 443,
        scheme: "https",
        # no discover on France Connect
        authorization_endpoint: "/api/v1/authorize",
        token_endpoint: "/api/v1/token",
        userinfo_endpoint: "/api/v1/userinfo"
      }

      info do
        {
          sub: user_info.sub,
          given_name: user_info.given_name,
          family_name: user_info.family_name,
          birthdate: user_info.birthdate.presence && Date.parse(user_info.birthdate),
          gender: user_info.gender,
          # birthplace: user_info.respond_to?(:birthplace) ? user_info.birthplace : nil, # does not seem to work yet
          # birthcountry: user_info.respond_to?(:birthcountry) ? user_info.birthcountry : nil, # does not seem to work yet
          phone: user_info.phone_number,
          email: user_info.email,
          preferred_username: user_info.preferred_username,
        }
      end
    end
  end
end

OmniAuth.config.add_camelization('france_connect', 'FranceConnect')
