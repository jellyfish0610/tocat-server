module Actions
  class AuthenticateRequest < Actions::BaseAction
    attr_reader :user

    def initialize(request: {})
      super()
      @request = request
    end

    def call
      detect_user
      self
    end

    private

    attr_reader :request

    def detect_user
      @user ||= User.find(decoded_auth_token[:user_id]) if decoded_auth_token
      @user ||= User.find_by(name: params[:current_user]) if legacy_auth?
      @user || push_errors('Invalid token') && nil
    end

    def decoded_auth_token
      @decoded_auth_token ||= JsonWebToken.decode(http_auth_header) if http_auth_header
    end

    def http_auth_header
      headers['Authorization'].split(' ').last if headers['Authorization'].present?
    end

    def authorized_hosts
      Settings.authorized_hosts
    end

    def legacy_auth?
      authorized_hosts.include?(client_host)
    end

    def headers
      request.headers
    end

    def params
      request.params
    end

    def client_host
      Resolv.getname(request.remote_ip)
    end
  end
end
