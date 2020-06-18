require 'omniauth/strategies/france_connect'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV["GITHUB_APP_ID"], ENV["GITHUB_APP_SECRET"], scope: 'user:email'

  provider(
    :france_connect,
    name: :france_connect,
    scope: [:openid, :profile, :email],
    issuer: "https://#{ENV['FRANCE_CONNECT_HOST']}",
    client_options: {
      identifier: ENV["FRANCE_CONNECT_APP_ID"],
      secret: ENV["FRANCE_CONNECT_APP_SECRET"],
      redirect_uri: "#{ENV['HOST']}/auth/france_connect/callback",
      host: ENV['FRANCE_CONNECT_HOST']
    }
  )

  on_failure { |env| AuthenticationsController.action(:failure).call(env) }
end
