module ApiUtils
    def api_require_valid_bearer_token!
        token = request.headers["Authorization"]
        # TODO: PUT THIS IN RAILS CREDENTIALS! ALSO IN THE API DOCS
        unless token ==
               "Bearer 3b589393da6bc000705e75c9ae2fec24442fe09bad96b1f31645f9813abc1924"
            json(
                {
                    success: false,
                    token: "bearer_token.invalid",
                    message: "Invalid bearer token"
                },
                :unauthorized
            )
        end
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
        decoded =
            JWT.decode(token, Rails.application.secret_key_base).first.to_options

        return(@api_user = User.find_by(id: decoded[:user_id])) if decoded[:expire] > Time.now.to_i

        nil
    rescue StandardError # JWT::VerificationError
        nil
    end

    def valid_access_token?
        !!api_current_user
    end

    def generate_access_token(user, expire = 1.year.from_now.to_i)
        payload = { user_id: user.id, expire: }

        JWT.encode(payload, Rails.application.secret_key_base)
    end

    def refresh_access_token
        token = request.headers["Access-token"]

        begin
            decoded =
                JWT.decode(token, Rails.application.secret_key_base).first.to_options

            if decoded[:expire] > Time.now.to_i
                payload = { user_id: decoded[:user_id], expire: 1.year.from_now.to_i }
                return JWT.encode(payload, Rails.application.secret_key_base)
            end

            nil
        rescue StandardError # JWT::VerificationError
            nil
        end
    end

    def validate_params(*check, hash: params)
        check.each { |p| return false unless hash[p] }
        true
    end

    def json(data, code = :ok)
        render json: data, status: code
    end
end
