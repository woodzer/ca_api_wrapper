#! /usr/bin/env ruby
# Copyright © 2015, Peter Wood.

module CrypticArchive
  module AuthenticationMethods
    # You must have established a Cryptic Archive session to call this method.
    # This method runs the authentication process for your session.
    #
    # ==== Parameters
    # code::  The authentication code to run through the authentication process.
    def authenticate(code)
      session_check!
      begin
        JSON.parse(post(full_path("authentications"), {code: code, session_id: session_id}))
      rescue => error
        handle_request_exception(error)
      end
    end

    # You must have established a Cryptic Archive session to call this method.
    # This method switches on authentication for your account. Note that the
    # ROTP code used by authenticator should be among the output returned from
    # this method.
    #
    # ==== Parameters
    # password::  The password associated with the current Cryptic Archive
    #             session.
    def activate_authentication(password)
      session_check!
      begin
        JSON.parse(put(full_path("authentications/activate"), {password: password, session_id: session_id}))
      rescue => error
        handle_request_exception(error)
      end
    end

    # You must have established a Cryptic Archive session to call this method.
    # This method switches off authentication for your account.
    #
    # ==== Parameters
    # password::  The password associated with the current Cryptic Archive
    #             session.
    def deactivate_authentication(password)
      session_check!
      begin
        JSON.parse(put(full_path("authentications/deactivate"), {password: password, session_id: session_id}))
      rescue => error
        handle_request_exception(error)
      end
    end
  end
end