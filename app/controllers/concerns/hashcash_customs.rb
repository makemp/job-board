module HashcashCustoms
  extend ActiveSupport::Concern

  included do
    include ActiveHashcash
  end

  def handle_check_hashcash(turbo_tag_to_be_replaced = nil)
    return unless ENV['HASHCASH_ENABLED'] == 'true'

    check_hashcash
  rescue ActionController::InvalidAuthenticityToken
    if request.xhr? || turbo_frame_request?
      raise "Missing tag to be replaced" if turbo_tag_to_be_replaced.nil?
      render turbo_stream: turbo_stream.replace(turbo_tag_to_be_replaced,
        partial: "shared/error_message",
        locals: {message: "You look like a bot."}), status: :unprocessable_entity
    else
      flash[:alert] = "You look like a bot."
      redirect_to root_path
    end
  end
end
