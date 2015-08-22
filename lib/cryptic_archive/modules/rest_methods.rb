#! /usr/bin/env ruby
# Copyright © 2015, Peter Wood.

module CrypticArchive
  module RESTMethods
    # Constants.
    DEFAULT_SCHEME           = "https"
    DEFAULT_HOST             = "www.crypticarchive.com"
    DEFAULT_ERROR            = "Unexpected error encountered processing request."

    # This method makes a GET request to a URL created by combining the
    # specified path with the base URL and appending any data parameters
    # provided.
    def get(path, data={})
      RestClient.get(full_url(path), {params: data})
    rescue RestClient::Exception => error
      message = "REST client exception caught processing GET request."
      log.error "#{message}\nCause: #{error}\n" +
                error.backtrace.join("\n")
      raise CAHTTPError.new(message, error, response: error.response, url: full_url(path))
    end

    # This method makes a POST request to a URL created by combining the
    # specified path with the base URL and sends the data provided.
    def post(path, data={})
      RestClient.post(full_url(path), data)
    rescue RestClient::Exception => error
      message = "REST client exception caught processing POST request."
      log.error "#{message}\nCause: #{error}\n" +
                error.backtrace.join("\n")
      raise CAHTTPError.new(message, error, response: error.response, url: full_url(path))
    end

    def delete(path, data={})
      if !data.empty?
        RestClient::Request.execute(method: :delete, payload: data, url: full_url(path))
      else
        RestClient.delete(full_url(path))
      end
    rescue RestClient::Exception => error
      message = "REST client exception caught processing DELETE request."
      log.error "#{message}\nCause: #{error}\n" +
                error.backtrace.join("\n")
      raise CAHTTPError.new(message, error, response: error.response, url: full_url(path))
    end

    def patch(path, data={})
      RestClient.patch(full_url(path), data)
    rescue RestClient::Exception => error
      message = "REST client exception caught processing PATCH request."
      log.error "#{message}\nCause: #{error}\n" +
                error.backtrace.join("\n")
      raise CAHTTPError.new(message, error, response: error.response, url: full_url(path))
    end

    def put(path, data={})
      RestClient.put(full_url(path), data)
    rescue RestClient::Exception => error
      message = "REST client exception caught processing PUT request."
      log.error "#{message}\nCause: #{error}\n" +
                error.backtrace.join("\n")
      raise CAHTTPError.new(message, error, response: error.response, url: full_url(path))
    end

    # Returns the HTTP scheme to be used when making requests.
    def scheme
      ENV['CA_SCHEME'] || DEFAULT_SCHEME
    end

    # Returns the HTTP host to make REST requests to.
    def host
      ENV['CA_HOST'] || DEFAULT_HOST
    end

    # Returns a string containing a combination of the schema and the host for
    # making REST requests to.
    def base_url
      "#{scheme}://#{host}"
    end

    # Returns a string containing the common element of the path shared by all
    # REST API endpoints.
    def base_path
      "/api/v1"
    end

    # Generates a fully qualified URL by combining the base URL with a path.
    def full_url(path)
      "#{base_url}#{path}"
    end

    # Generates a fully qualified URL by combining the base path with a custom
    # component.
    def full_path(custom)
      "#{base_path}/#{custom}"
    end

    # This method handles when a response from the REST API server does not
    # contain success details. The method assesses the content and then
    # generates an exception based on what it finds.
    def handle_error_response(response)
      message = code = nil
      if response.include?("error")
        error   = response["error"]
        message = (error["message"] || DEFAULT_ERROR)
        code    = error["code"]
      else
        message = DEFAULT_ERROR
      end
      log.error "Error response received from server.\nMessage: #{message}\nCode: #{code}"
      case code
        when "errors.sessions.authorization_required"
          raise CAAuthorizationError.new(message, nil, code: code)
        when "errors.sessions.authentication_required"
          raise CAAuthenticationError.new(message, nil, code: code)
        else
          raise CAError.new(message, nil, code: code)
      end
    end

    # This method handles exception raised when making a REST API request.
    def handle_request_exception(exception)
      # puts "ERROR: #{exception}\n" + exception.backtrace.join("\n")
      handle_error_response(exception.kind_of?(CAHTTPError) ? JSON.parse(exception.response) : {})
    end
  end
end