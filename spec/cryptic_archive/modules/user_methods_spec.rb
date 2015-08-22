require "spec_helper"

describe CrypticArchive::UserMethods do
  let(:session_id) {
    SecureRandom.uuid
  }
  subject {
    CrypticArchive::Session.new
  }

  #-----------------------------------------------------------------------------
  # #user()
  #-----------------------------------------------------------------------------
  describe "#user()" do
    describe "when a session already exists" do
      before do
        subject.session_id = session_id
      end

      describe "and the server responds with success" do
        let(:response) {
          {success: true,
           user: {id: SecureRandom.uuid, handle: "UserHandle", status: "Active"}}
        }

        it "returns a Hash of user information" do
          expect(subject).to receive(:get).with("/api/v1/users/me").and_return(response.to_json).once
          output = subject.user
          expect(output).to eq(JSON.parse(response[:user].to_json))
        end
      end

      describe "and the server responds with an error" do
        let(:response) {
          {success: false,
           error: {code: "some.error.code", message: "An error message."}}
        }

        before do
          stub_request(:get, "https://www.crypticarchive.com/api/v1/users/me").
            to_return(:status => 400, :body => response.to_json, :headers => {})
        end

        it "raises an exception" do
          expect {
            subject.user
          }.to raise_exception(CrypticArchive::CAError, "An error message.")
        end
      end
    end

    describe "when a session hasn't yet been established" do
      it "raises an exception" do
        expect {
          subject.user
        }.to raise_exception(CrypticArchive::CAError, "You are not connected to the server.")
      end
    end
  end
end