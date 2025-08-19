class HealthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  skip_before_action :verify_authenticity_token, only: [:index]

  def index
    render json: {
      status: 'ok',
      timestamp: Time.current.iso8601,
      version: Rails.application.config.chatwoot_version || 'unknown'
    }, status: :ok
  rescue StandardError => e
    render json: {
      status: 'error',
      message: e.message,
      timestamp: Time.current.iso8601
    }, status: :service_unavailable
  end
end
