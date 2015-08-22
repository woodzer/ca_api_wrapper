#! /usr/bin/env ruby
# Copyright © 2015, Peter Wood.

module CrypticArchive
  class Session
    # Include modules.
    include AuthenticationMethods
    include RecordMethods
    include RESTMethods
    include SessionMethods
    include UserMethods

    def initialize(options={})
      @session_id = options[:session_id]
      if @session_id.nil? && options.include?(:handle) && options.include?(:password)
        @session_id = connect(options[:handle], options[:password])
      end
    end
    attr_reader :handle, :password
    attr_accessor :session_id

    # This method creates a new Cryptic Archive account. You will need to log in
    # separately after creating the account.
    def self.signup(handle)
      session = self.new
      begin
        JSON.parse(session.post(session.full_path("users"), {handle: handle}))
      rescue => error
        session.handle_request_exception(error)
      end
    end
  end
end