#! /usr/bin/env ruby
# Copyright © 2015, Peter Wood.

module CrypticArchive
  module SessionMethods
    # This method connects to the Cryptic Archive server and attempts to create
    # a new session using the users handle and password.
    #
    # ==== Parameters
    # handle::    The user handle to be used in establishing the Cryptic Archive
    #             session.
    # password::  The password to be used in establishing the Cryptic Archive
    #             session.
    def connect(handle, password)
      response = JSON.parse(post(full_path("sessions"), {handle: handle, password: password}))
      if !response.include?("session_id")
        raise CAError.new "Invalid response received from server."
      end
      session_id = response["session_id"]
      response
    rescue => error
      handle_request_exception(error)
    end
    alias :open :connect

    # This method terminates an active Cryptic Archive session.
    def terminate
      output = nil
      if session_id
        output = JSON.parse(delete(full_path("sessions/#{session_id}")))
        self.session_id = nil
      end
      output
    rescue => error
      handle_request_exception(error)
    end
    alias :disconnect :terminate
    alias :close :terminate

    # This method pings an existing Cryptic Archive session to extend its
    # lifespan.
    def touch
      session_check!
      begin
        JSON.parse(put(full_path("sessions/#{session_id}")))
      rescue => error
        handle_request_exception(error)
      end
    end

    # This method is used to test whether a Cryptic Archive session has been
    # established.
    def connected?
      !session_id.nil?
    end

    # This method is used internally to check that the user has established a
    # session before performing other actions. The method raises an exception
    # if a session hasn't been established.
    def session_check!
      raise CAError.new("You are not connected to the server.") if !connected?
    end
  end
end