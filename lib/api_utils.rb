module ApiUtils
    def api_require_valid_bearer_token!
        token = request.headers["Authorization"]
        return if token == Rails.application.credentials[:api_bearer_token]

        json(
            {
                success: false,
                token: "bearer_token.invalid",
                message: "Invalid bearer token"
            },
            :unauthorized
        )
    end

    def api_require_valid_access_token!
        unless valid_access_token?
            json(
                {
                    success: false,
                    token: "access_token.invalid",
                    message: "Access token is invalid"
                },
                :unauthorized
            )
        end
        valid_access_token?
    end

    def api_current_user
        token = request.headers["Access-token"]
        @api_user = User.find_signed token, purpose: :api_token
    end

    def valid_access_token?
        !!api_current_user
    end

    def generate_access_token(user, expires_in = 20.years)
        user.signed_id purpose: :api_token, expires_in:
    end

    def refresh_access_token
        token = request.headers["Access-token"]
        user = User.find_signed token, purpose: :api_token

        return nil unless user.present?

        generate_access_token user
    end

    def validate_params(*check, hash: params)
        check.each { |p| return false unless hash[p] }
        true
    end

    def json(data, code = :ok)
        render json: data, status: code
    end
end
