class ApplicationController < ActionController::API
  #before_filter :check_format
  include ActionController::Serialization

  def default_serializer_options
    { root: false }
  end

  def error_builder(object)
    if object.errors[:base][0].nil?
      message = object.errors.first.second
    else
      message = object.errors[:base][0]
    end
    { error: "#{object.class.name.upcase}_ERROR", message: message }
  end

  private

  def check_format
    return true if %w(GET DELETE).include? request.method
    #binding.pry
    if request.format != Mime::JSON || request.content_type != 'application/json'
      render json: { error: 'ERROR', message: "Format #{request.content_type} not supported for #{request.path}" }
      return 0
    end
  end
end
