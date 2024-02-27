module Exceptions
  class Base < StandardError
    attr_reader :code, :message

    def initialize(code: nil, message: nil, **options)
      super()

      @code = code
      @message = message
    end
  end

  class UserNotFound < Exceptions::Base
    def initialize
      super(message: 'User not found.', code: 10001)
    end
  end

  class UserNotAuthorized < Exceptions::Base
    def initialize
      super(message: 'User not authorized.', code: 10002)
    end
  end

  class InvalidGrantType < Exceptions::Base
    def initialize
      super(message: 'Invalid grant type.', code: 20001)
    end
  end

  class ExpiredSignature < Exceptions::Base
    def initialize
      super(message: 'Signature has expired.', code: 30001)
    end
  end
end
