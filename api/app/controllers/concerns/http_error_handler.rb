# frozen_string_literal: true

module HttpErrorHandler
  class << self
    def included(clazz)
      clazz.class_eval do
        rescue_from Exception, with: :rescue_from_exception
        rescue_from Errors::CustomError, with: :rescue_from_custom_error
      end
    end
  end

  private

  def respond(error, status)
    case error
    when String then render json: { message: error }, status: status
    when Hash then render json: error, status: status
    else render status: status
    end
  end

  def rescue_from_exception(exception)
    backtrace = exception.backtrace&.first.to_s
    path, line_number, method_name = backtrace.split(":")

    message = <<~MESSAGE
      Failed to execute controller action.

      Path: #{path},
      Class: #{self.class.name},
      Method: #{method_name&.split('`')&.second || 'unknown_method'},
      Line: #{line_number},
      Error: #{exception.message[0..500]},

      Request ID: #{request.request_id},
      Request Path: #{request.path},
      HTTP Method: #{request.method},
      Params: #{request.params.to_json}
    MESSAGE

    Rails.logger.error message
    respond("Internal Server Error", :internal_server_error)
  end

  def rescue_from_custom_error(exception)
    respond(exception.body, exception.status)
  end
end
