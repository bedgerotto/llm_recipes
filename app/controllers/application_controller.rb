class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from StandardError, with: :render_error_response

  def render_error_response(error)
    render json: { recipe: { valid: false, reason: error.message } }, status: 422
  end
end
