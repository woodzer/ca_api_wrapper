require "spec_helper"

describe CrypticArchive::SessionMethods do
  let(:handle) {
    "my_handle"
  }
  let(:password) {
    "password"
  }
  let(:session_id) {
    SecureRandom.uuid
  }
  subject {
    CrypticArchive::Session.new()
  }

  #-----------------------------------------------------------------------------
  # #connect()
  #-----------------------------------------------------------------------------
  describe "#connect()" do
    describe "when the server responds with success" do
      let(:response) {
        {success: true, session_id: session_id}
      }

      it "posts a request with the user handle and password to the REST API server" do
        expect(subject).to receive(:post).with("/api/v1/sessions", {handle: handle, password: password}).and_return(response.to_json).once
        output = subject.connect(handle, password)
        expect(output).to eq(JSON.parse(response.to_json))
      end
    end

    describe "when the server response is an error" do
      let(:response) {
        {success: false, error: {code: "errors.sessions.invalid_credentials", message: "Invalid credentials specified."}}
      }

      before do
        stub_request(:post, "https://www.crypticarchive.com/api/v1/sessions").
          to_return(:status => 401, :body => response.to_json, :headers => {})
      end

      it "raises an exception" do
        expect {
          subject.connect(handle, password)
        }.to raise_exception(CrypticArchive::CAError, "Invalid credentials specified.")
      end
    end
  end

  #-----------------------------------------------------------------------------
  # #terminate()
  #-----------------------------------------------------------------------------
  describe "#terminate()" do
    describe "when a session already exists" do
      before do
        subject.session_id = session_id
      end

      describe "and the server responds with success" do
        let(:response) {
          {success: true}
        }

        it "sends a delete request with the session id to the REST API server" do
          expect(subject).to receive(:delete).with("/api/v1/sessions/#{session_id}").and_return(response.to_json).once
          output = subject.terminate
          expect(output).to eq(JSON.parse(response.to_json))
          expect(subject.session_id).to be_nil
        end
      end

      describe "and the server response is an error" do
        let(:response) {
          {success: false, error: {code: "errors.sessions.failed", message: "An error occurred."}}
        }

        before do
          stub_request(:delete, "https://www.crypticarchive.com/api/v1/sessions/#{session_id}").
            to_return(:status => 400, :body => response.to_json, :headers => {})
        end

        it "raises an exception" do
          expect {
            subject.terminate
          }.to raise_exception(CrypticArchive::CAError, "An error occurred.")
        end
      end
    end

    describe "when a session does not already exist" do
      it "does nothing" do
        expect(subject).not_to receive(:delete)
        expect {
          subject.terminate
        }.not_to raise_exception
      end
    end
  end

  #-----------------------------------------------------------------------------
  # #touch()
  #-----------------------------------------------------------------------------
  describe "#touch()" do
    describe "when a session already exists" do
      before do
        subject.session_id = session_id
      end

      describe "and the server responds with success" do
        let(:response) {
          {success: true}
        }

        it "sends a put request with the session id to the REST API server" do
          expect(subject).to receive(:put).with("/api/v1/sessions/#{session_id}").and_return(response.to_json).once
          output = subject.touch
          expect(output).to eq(JSON.parse(response.to_json))
        end
      end

      describe "and the server responds with an error" do
        let(:response) {
          {success: false, error: {code: "errors.sessions.failed", message: "An error occurred."}}
        }

        before do
          stub_request(:put, "https://www.crypticarchive.com/api/v1/sessions/#{session_id}").
            to_return(:status => 400, :body => response.to_json, :headers => {})
        end

        it "raises an exception" do
          expect {
            subject.touch
          }.to raise_exception(CrypticArchive::CAError, "An error occurred.")
        end
      end
    end

    describe "when a session does not already exists" do
      it "raises an exception" do
        expect {
          subject.touch
        }.to raise_exception(CrypticArchive::CAError, "You are not connected to the server.")
      end
    end
  end

  #-----------------------------------------------------------------------------
  # #connected?()
  #-----------------------------------------------------------------------------
  describe "#connected?()" do
    it "returns true if a session has been established" do
      subject.session_id = session_id
      expect(subject.connected?).to eq(true)
    end

    it "returns false if a session has not been established" do
      expect(subject.connected?).to eq(false)
    end
  end
end
