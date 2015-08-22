require "spec_helper"

describe CrypticArchive::RESTMethods do
  class RESTMethodsTestClass
    include CrypticArchive::RESTMethods
  end

  subject {
    RESTMethodsTestClass.new
  }

  #-----------------------------------------------------------------------------
  # #base_url()
  #-----------------------------------------------------------------------------
  describe "#base_url()" do
    it "returns the combined scheme and host as an URL string" do
      expect(subject.base_url).to eq("#{CrypticArchive::RESTMethods::DEFAULT_SCHEME}://#{CrypticArchive::RESTMethods::DEFAULT_HOST}")
    end
  end

  #-----------------------------------------------------------------------------
  # #delete()
  #-----------------------------------------------------------------------------
  describe "#delete()" do
    let(:session_id) {
      SecureRandom.uuid
    }

    describe "with parameters" do
      describe "when the server responds with success" do
        let(:response) {
          {success: true}
        }
        before do
          stub_request(:delete, "https://www.crypticarchive.com/api/v1/sessions/#{session_id}").
            to_return(:status => 200, :body => response.to_json, :headers => {})
        end

        it "makes a HTTP get request to the base URL and path specified and returns a response" do
          output = subject.delete("/api/v1/sessions/#{session_id}")
          expect(output).to eq(response.to_json)
        end
      end

      describe "when the server responds with an error" do
        let(:response) {
          {success: false, error: {code: "an.error", message: "An error."}}
        }
        before do
          stub_request(:delete, "https://www.crypticarchive.com/api/v1/sessions/#{session_id}").
            to_return(:status => 400, :body => response.to_json, :headers => {})
        end

        it "makes a HTTP get request to the base URL and path specified and raises an exception" do
          expect {
            subject.delete("/api/v1/sessions/#{session_id}")
          }.to raise_exception(CrypticArchive::CAError, "REST client exception caught processing DELETE request.")
        end
      end
    end

    describe "with parameters" do
        let(:parameters) {
          {handle: "me", password: "password"}
        }
        let(:response) {
          {success: true}
        }
        before do
          stub_request(:delete, "https://www.crypticarchive.com/api/v1/sessions/#{session_id}").
            with(body: {"handle"=>"me", "password"=>"password"}).
            to_return(:status => 200, :body => "", :headers => {})
        end

      it "passes the parameters as part of the request" do
        subject.delete("/api/v1/sessions/#{session_id}", parameters)
      end
    end
  end

  #-----------------------------------------------------------------------------
  # #full_path()
  #-----------------------------------------------------------------------------
  describe "#full_path()" do
    it "returns the base path prefixed to the path element specified" do
      expect(subject.full_path("one/two")).to eq("#{subject.base_path}/one/two")
    end
  end

  #-----------------------------------------------------------------------------
  # #full_url()
  #-----------------------------------------------------------------------------
  describe "#full_url()" do
    it "returns an URL string containing the base URL prefixed to the path specified" do
      expect(subject.full_url("/one/two")).to eq("#{subject.base_url}/one/two")
    end
  end

  #-----------------------------------------------------------------------------
  # #get()
  #-----------------------------------------------------------------------------
  describe "#get()" do
    let(:parameters) {
      {handle: "me", password: "password"}
    }

    describe "when the server responds with success" do
      let(:response) {
        {success: true, session_id: SecureRandom.uuid}
      }
      before do
        stub_request(:get, "https://www.crypticarchive.com/api/v1/sessions?handle=me&password=password").
          to_return(:status => 200, :body => response.to_json, :headers => {})
      end

      it "makes a HTTP get request to the base URL and path specified and returns a response" do
        output = subject.get("/api/v1/sessions", parameters)
        expect(output).to eq(response.to_json)
      end
    end

    describe "when the server responds with an error" do
      let(:response) {
        {success: false, error: {code: "an.error", message: "An error."}}
      }
      before do
        stub_request(:get, "https://www.crypticarchive.com/api/v1/sessions?handle=me&password=password").
          to_return(:status => 400, :body => response.to_json, :headers => {})
      end

      it "makes a HTTP get request to the base URL and path specified and raises an exception" do
        expect {
          subject.get("/api/v1/sessions", parameters)
        }.to raise_exception(CrypticArchive::CAError, "REST client exception caught processing GET request.")
      end
    end
  end

  #-----------------------------------------------------------------------------
  # #handle_error_response()
  #-----------------------------------------------------------------------------
  describe "#handle_error_response()" do
    describe "when the response specified contains an error entry" do
      describe "when the error is an authorization error" do
        let(:response) {
          {"error"   => {"code" => "errors.sessions.authorization_required", "message" => "Authorization error."},
           "success" => false}
        }

        it "raises an authorization exception" do
          expect {
            subject.handle_error_response(response)
          }.to raise_exception(CrypticArchive::CAAuthorizationError, "Authorization error.")
        end
      end

      describe "when the error is an authentication error" do
        let(:response) {
          {"error"   => {"code" => "errors.sessions.authentication_required", "message" => "Authentication error."},
           "success" => false}
        }

        it "raises an authorization exception" do
          expect {
            subject.handle_error_response(response)
          }.to raise_exception(CrypticArchive::CAAuthenticationError, "Authentication error.")
        end
      end

      describe "when the error is not an authorization or authentication error" do
        let(:response) {
          {"error"   => {"code" => "some.kind.of.error", "message" => "Some kind of error occurred."},
           "success" => false}
        }

        it "raises a generic CAError" do
          expect {
            subject.handle_error_response(response)
          }.to raise_exception(CrypticArchive::CAError, "Some kind of error occurred.")
        end
      end
    end

    describe "when the response specified does not contain an error entry" do
      it "raises a generic CAError" do
        expect {
          subject.handle_error_response({"success" => false})
        }.to raise_exception(CrypticArchive::CAError, CrypticArchive::RESTMethods::DEFAULT_ERROR)
      end
    end
  end

  #-----------------------------------------------------------------------------
  # #host()
  #-----------------------------------------------------------------------------
  describe "#host()" do
    describe "when no environment setting is available" do
      it "returns the default host setting" do
        expect(subject.host).to eq(CrypticArchive::RESTMethods::DEFAULT_HOST)
      end
    end

    describe "when an environment setting is available" do
      before do
        ENV["CA_HOST"] = "www.blah.com"
      end

      after do
        ENV.delete("CA_HOST")
      end

      it "returns the host set in the environment setting" do
        expect(subject.host).to eq("www.blah.com")
      end
    end
  end

  #-----------------------------------------------------------------------------
  # #patch()
  #-----------------------------------------------------------------------------
  describe "#patch()" do
    let(:parameters) {
      {handle: "UserName"}
    }

    describe "when the server responds with success" do
      let(:response) {
        {success: true}
      }
      before do
        stub_request(:patch, "https://www.crypticarchive.com/api/v1/users").
          with(body: {"handle"=>"UserName"}).
          to_return(:status => 200, :body => response.to_json, :headers => {})
      end

      it "makes a HTTP patch request to the base URL and path specified and returns a response" do
        output = subject.patch("/api/v1/users", parameters)
        expect(output).to eq(response.to_json)
      end
    end

    describe "when the server responds with an error" do
      let(:response) {
        {success: false, error: {code: "an.error", message: "An error."}}
      }
      before do
        stub_request(:patch, "https://www.crypticarchive.com/api/v1/users").
          with(body: {"handle"=>"UserName"}).
          to_return(:status => 401, :body => response.to_json, :headers => {})
      end

      it "makes a HTTP post request to the base URL and path specified and raises an exception" do
        expect {
          subject.patch("/api/v1/users", parameters)
        }.to raise_exception(CrypticArchive::CAError, "REST client exception caught processing PATCH request.")
      end
    end
  end

  #-----------------------------------------------------------------------------
  # #post()
  #-----------------------------------------------------------------------------
  describe "#post()" do
    let(:parameters) {
      {handle: "UserName"}
    }

    describe "when the server responds with success" do
      let(:response) {
        {success: true}
      }
      before do
        stub_request(:post, "https://www.crypticarchive.com/api/v1/sessions").
          with(:body => {"handle"=>"UserName"}).
          to_return(:status => 200, :body => response.to_json, :headers => {})
      end

      it "makes a HTTP post request to the base URL and path specified and returns a response" do
        output = subject.post("/api/v1/sessions", parameters)
        expect(output).to eq(response.to_json)
      end
    end

    describe "when the server responds with an error" do
      let(:response) {
        {success: false, error: {code: "an.error", message: "An error."}}
      }
      before do
        stub_request(:post, "https://www.crypticarchive.com/api/v1/sessions").
          with(body: {"handle"=>"UserName"}).
          to_return(:status => 400, :body => response.to_json, :headers => {})
      end

      it "makes a HTTP post request to the base URL and path specified and raises an exception" do
        expect {
          subject.post("/api/v1/sessions", parameters)
        }.to raise_exception(CrypticArchive::CAError, "REST client exception caught processing POST request.")
      end
    end
  end

  #-----------------------------------------------------------------------------
  # #put()
  #-----------------------------------------------------------------------------
  describe "#patch()" do
    let(:parameters) {
      {handle: "UserName"}
    }

    describe "when the server responds with success" do
      let(:response) {
        {success: true}
      }
      before do
        stub_request(:put, "https://www.crypticarchive.com/api/v1/users").
          with(body: {"handle"=>"UserName"}).
          to_return(:status => 200, :body => response.to_json, :headers => {})
      end

      it "makes a HTTP put request to the base URL and path specified and returns a response" do
        output = subject.put("/api/v1/users", parameters)
        expect(output).to eq(response.to_json)
      end
    end

    describe "when the server responds with an error" do
      let(:response) {
        {success: false, error: {code: "an.error", message: "An error."}}
      }
      before do
        stub_request(:put, "https://www.crypticarchive.com/api/v1/users").
          with(body: {"handle"=>"UserName"}).
          to_return(:status => 401, :body => response.to_json, :headers => {})
      end

      it "makes a HTTP put request to the base URL and path specified and raises an exception" do
        expect {
          subject.put("/api/v1/users", parameters)
        }.to raise_exception(CrypticArchive::CAError, "REST client exception caught processing PUT request.")
      end
    end
  end

  #-----------------------------------------------------------------------------
  # #scheme()
  #-----------------------------------------------------------------------------
  describe "#scheme()" do
    describe "when no environment setting is available" do
      it "returns the default scheme setting" do
        expect(subject.scheme).to eq(CrypticArchive::RESTMethods::DEFAULT_SCHEME)
      end
    end

    describe "when an environment setting is available" do
      before do
        ENV["CA_SCHEME"] = "file"
      end

      after do
        ENV.delete("CA_SCHEME")
      end

      it "returns the scheme set in the environment setting" do
        expect(subject.scheme).to eq("file")
      end
    end
  end
end