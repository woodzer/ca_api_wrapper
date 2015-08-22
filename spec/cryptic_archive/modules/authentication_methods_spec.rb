require "spec_helper"

describe CrypticArchive::AuthenticationMethods do
  let(:code) {
    "123456"
  }
  let(:password) {
    "password"
  }
  let(:session_id) {
    SecureRandom.uuid
  }
  subject {
    CrypticArchive::Session.new
  }

  #-----------------------------------------------------------------------------
  # #authenticate()
  #-----------------------------------------------------------------------------
  describe "#authenticate()" do
    describe "when a session already exists" do
      before do
        subject.session_id = session_id
      end

      describe "and the server responds with success" do
        let(:response) {
          {success: true}
        }

        it "returns success" do
          expect(subject).to receive(:post).with("/api/v1/authentications", {code: code, session_id: session_id}).and_return(response.to_json).once
          output = subject.authenticate(code)
          expect(output).to eq(JSON.parse(response.to_json))
        end
      end

      describe "and the server responds with an error" do
        let(:response) {
          {success: false,
           error: {code: "some.error.code", message: "An error message."}}
        }

        before do
          stub_request(:post, "https://www.crypticarchive.com/api/v1/authentications").
            to_return(:status => 400, :body => response.to_json, :headers => {})
        end

        it "raises an exception" do
          expect {
            subject.authenticate(code)
          }.to raise_exception(CrypticArchive::CAError, "An error message.")
        end
      end
    end

    describe "when a session hasn't yet been established" do
      it "raises an exception" do
        expect {
          subject.authenticate(code)
        }.to raise_exception(CrypticArchive::CAError, "You are not connected to the server.")
      end
    end
  end

  #-----------------------------------------------------------------------------
  # #activate_authentication()
  #-----------------------------------------------------------------------------
  describe "#activate_authenticate()" do
    describe "when a session already exists" do
      before do
        subject.session_id = session_id
      end

      describe "and the server responds with success" do
        let(:response) {
          {success: true}
        }

        it "returns success" do
          expect(subject).to receive(:put).with("/api/v1/authentications/activate", {password: password, session_id: session_id}).and_return(response.to_json).once
          output = subject.activate_authentication(password)
          expect(output).to eq(JSON.parse(response.to_json))
        end
      end

      describe "and the server responds with an error" do
        let(:response) {
          {success: false,
           error: {code: "some.error.code", message: "An error message."}}
        }

        before do
          stub_request(:put, "https://www.crypticarchive.com/api/v1/authentications/activate").
            to_return(:status => 400, :body => response.to_json, :headers => {})
        end

        it "raises an exception" do
          expect {
            subject.activate_authentication(password)
          }.to raise_exception(CrypticArchive::CAError, "An error message.")
        end
      end
    end

    describe "when a session hasn't yet been established" do
      it "raises an exception" do
        expect {
          subject.activate_authentication(password)
        }.to raise_exception(CrypticArchive::CAError, "You are not connected to the server.")
      end
    end
  end

  #-----------------------------------------------------------------------------
  # #deactivate_authentication()
  #-----------------------------------------------------------------------------
  describe "#deactivate_authenticate()" do
    describe "when a session already exists" do
      before do
        subject.session_id = session_id
      end

      describe "and the server responds with success" do
        let(:response) {
          {success: true}
        }

        it "returns success" do
          expect(subject).to receive(:put).with("/api/v1/authentications/deactivate", {password: password, session_id: session_id}).and_return(response.to_json).once
          output = subject.deactivate_authentication(password)
          expect(output).to eq(JSON.parse(response.to_json))
        end
      end

      describe "and the server responds with an error" do
        let(:response) {
          {success: false,
           error: {code: "some.error.code", message: "An error message."}}
        }

        before do
          stub_request(:put, "https://www.crypticarchive.com/api/v1/authentications/deactivate").
            to_return(:status => 400, :body => response.to_json, :headers => {})
        end

        it "raises an exception" do
          expect {
            subject.deactivate_authentication(password)
          }.to raise_exception(CrypticArchive::CAError, "An error message.")
        end
      end
    end

    describe "when a session hasn't yet been established" do
      it "raises an exception" do
        expect {
          subject.deactivate_authentication(password)
        }.to raise_exception(CrypticArchive::CAError, "You are not connected to the server.")
      end
    end
  end
end