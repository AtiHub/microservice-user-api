module RequestHelpers
  module JsonHelpers
    def json
      @json ||= JSON.parse(response.body)
    end
  end

  module AuthorizationHelpers
    def header_with_content_type
      {
        'ACCEPT': 'application/json',
        'Content-Type': 'application/json',
      }
    end
  end
end
