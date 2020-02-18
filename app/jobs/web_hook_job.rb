class WebHookJob < ApplicationJob
  ENDPOINT = ENV["WEBHOOK_ENDPOINT"]
  TIMEOUT = 10

  def perform(rdv)
    return unless ENDPOINT

    Typhoeus.post(
      ENDPOINT,
      headers: { 'Content-Type' => 'application/json; charset=utf-8' },
      body: rdv.to_json,
      timeout: TIMEOUT
    )
  end
end
