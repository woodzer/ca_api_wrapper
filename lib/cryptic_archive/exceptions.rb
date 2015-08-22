#! /usr/bin/env ruby
# Copyright © 2015, Peter Wood.

module CrypticArchive
  class CAError < StandardError
    def initialize(message, cause=nil, context={})
      super(message)
      @cause   = cause
      @context = context
    end
    attr_reader :cause, :context
  end

  class CAHTTPError < CAError
    def response
      context[:response]
    end
  end

  class CAAuthorizationError < CAHTTPError
  end

  class CAAuthenticationError < CAHTTPError
  end
end
