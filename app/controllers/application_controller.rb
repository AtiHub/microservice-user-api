class ApplicationController < ActionController::API
  include TokenHelper

  rescue_from Exception, with: :render_error
  rescue_from Exceptions::Base, with: :render_error

  rescue_from Exceptions::UserNotAuthorized, with: :user_error
  rescue_from Exceptions::UserNotFound, with: :user_error
  rescue_from Exceptions::ExpiredSignature, with: :user_error

  rescue_from ActiveRecord::RecordInvalid do |error|
    render_model_errors(error.record)
  end

  rescue_from ActiveRecord::RecordNotFound do |error|
    render(json: { errors: [{ message: "#{error.model} not found!" }] }, status: 422)
  end

  def render_error(exception, status = 422)
    code = exception.code if exception.respond_to?(:code)

    errors = if exception.is_a?(String)
      [{ message: exception, code: code }]
    else
      [{ message: exception.message, code: code }]
    end

    render(json: { errors: errors }, status: status)
  end

  def user_error(exception, status = 401)
    render(json: { errors: [{ message: exception.message, code: exception&.code }] }, status: status)
  end

  def render_model_errors(object)
    render(json: { errors: model_errors(object) }, status: 422)
  end

  def model_errors(object)
    object.errors.messages.map do |k, v|
      v.map do |message|
        {
          code: 111,
          message: "#{k} - #{message}",
          key: k,
        }
      end
    end.flatten
  end
end
