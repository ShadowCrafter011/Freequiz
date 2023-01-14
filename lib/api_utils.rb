module ApiUtils
    def api_require_valid_bearer_token!
        token = request.headers["Authorization"]
        json({success: false, message: "Invalid bearer token"}, :unauthorized) unless token == "Bearer 3b589393da6bc000705e75c9ae2fec24442fe09bad96b1f31645f9813abc1924"
    end

    def api_require_valid_access_token!
        json({success: false, message: "Access token is invalid"}, :unauthorized) unless valid_access_token?
        return valid_access_token?
    end

    def api_current_user
        begin
            token = request.headers["Access-token"]
            decoded = JWT.decode(token, Rails.application.secret_key_base).first.to_options
            
            if decoded[:expire] > Time.now.to_i
                return (@api_user = User.find(decoded[:user_id]))
            end

            return nil

        rescue #JWT::VerificationError
            return nil
        end
    end

    def valid_access_token?
        !!api_current_user
    end

    def generate_access_token(user, expire=1.year.from_now.to_i)
        payload = {
            user_id: user.id,
            expire: expire
        }

        JWT.encode(payload, Rails.application.secret_key_base)
    end

    def refresh_access_token
        token = request.headers["Access-token"]

        begin
            decoded = JWT.decode(token, Rails.application.secret_key_base).first.to_options

            if decoded[:expire] > Time.now.to_i
                payload = {
                    user_id: decoded[:user_id],
                    expire: 1.year.from_now.to_i
                }
                return JWT.encode(payload, Rails.application.secret_key_base)
            end

            return nil

        rescue #JWT::VerificationError
            return nil
        end
    end

    def validate_params(*check, hash: params)
        check.each do |p|
            return false unless hash[p]
        end
        return true
    end

    def json(data, code=:ok)
        render json: data, status: code
    end
end