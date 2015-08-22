#! /usr/bin/env ruby
# Copyright © 2015, Peter Wood.

module CrypticArchive
  module UserMethods
    # You must have established a Cryptic Archive session to call this method.
    # The method returns details of the user for the current session.
    def user
      session_check!
      begin
        output = JSON.parse(get(full_path("users/me")))
        output["user"]
      rescue => error
        handle_request_exception(error)
      end
    end
  end
end