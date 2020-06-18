require 'omniauth/strategies/france_connect'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV["GITHUB_APP_ID"], ENV["GITHUB_APP_SECRET"], scope: 'user:email'
  on_failure { |env| AuthenticationsController.action(:failure).call(env) }
end
