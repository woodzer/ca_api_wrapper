#! /usr/bin/env ruby
# Copyright © 2015, Peter Wood.

module CrypticArchive
  module RecordMethods
    # This method requires that you have a established a Cryptic Archive session
    # before you can call it. The method creates a new Cryptic Archive record
    # for your account given the details provided.
    #
    # ==== Parameters
    # title::    The title for the new record.
    # type::     The type for the new record.
    # content::  The content for the record. Defaults to an empty Hash.
    def create_record(title, type, content={})
      session_check!
      begin
        parameters = {content: {title: title, type: type}.merge(content),
                      session_id: session_id}
        JSON.parse(post(full_path("records"), parameters))
      rescue => error
        handle_request_exception(error)
      end
    end

    # This method requires that you have a established a Cryptic Archive session
    # before you can call it. The method deletes a specific record from the
    # Cryptic Archive system.
    #
    # ==== Parameters
    # record_id::  The unique identifier for the record to delete.
    def delete_record(record_id)
      session_check!
      begin
        JSON.parse(delete(full_path("records/#{record_id}"), {session_id: session_id}))
      rescue => error
        handle_request_exception(error)
      end
    end

    # This method requires that you have a established a Cryptic Archive session
    # before you can call it. The method fetches complete detail for a specific
    # Cryptic Archive record.
    #
    # ==== Parameters
    # record_id::  The unique identifier for the record to retrieve.
    def get_record(record_id)
      session_check!
      begin
        output = JSON.parse(get(full_path("records/#{record_id}"), {session_id: session_id}))
        output["record"]
      rescue => error
        handle_request_exception(error)
      end
    end

    # This method requires that you have a established a Cryptic Archive session
    # before you can call it. The method fetches a short form listing of all of
    # the records available via the current Cryptic Archive session.
    def list_records
      session_check!
      begin
        output = JSON.parse(get(full_path("records"), {session_id: session_id}))
        output["records"]
      rescue => error
        handle_request_exception(error)
      end
    end

    # This method requires that you have a established a Cryptic Archive session
    # before you can call it. The method updates an existing Cryptic Archive
    # records details.
    #
    # ==== Parameters
    # record_id::  The unique identifier of the record to be updated.
    # content::    The content for the record. Defaults to an empty Hash.
    def update_record(record_id, content={})
      session_check!
      begin
        JSON.parse(put(full_path("records/#{record_id}"), {content: content, session_id: session_id}))
      rescue => error
        handle_request_exception(error)
      end
    end
  end
end