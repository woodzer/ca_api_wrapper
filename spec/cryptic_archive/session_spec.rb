require "spec_helper"

describe CrypticArchive::Session do
  #-----------------------------------------------------------------------------
  # #signup()
  #-----------------------------------------------------------------------------
  describe "#signup()" do
    let(:handle) {
      "MyUserHandle"
    }
    let(:session) {
      CrypticArchive::Session.new
    }
    subject {
      CrypticArchive::Session
    }

    describe "when the server responds with success" do
      let(:response) {
        {success: true}
      }

      it "makes a post request to the REST API server and returns without error" do
        allow(CrypticArchive::Session).to receive(:new).and_return(session)
        expect(session).to receive(:post).with("/api/v1/users", {handle: handle}).and_return(response.to_json).once
        output = subject.signup(handle)
        expect(output).to eq(JSON.parse(response.to_json))
      end
    end

    describe "when the server responds an error" do
      let(:response) {
        {success: false, error: {code: "errors.users.signup.duplicate_handle", message: "The handle '#{handle}' is already in use."}}
      }

      before do
        stub_request(:post, "https://www.crypticarchive.com/api/v1/users").
          to_return(:status => 400, :body => response.to_json, :headers => {})
      end

      it "raises an exception" do
        expect {
          subject.signup(handle)
        }.to raise_exception(CrypticArchive::CAError, "The handle '#{handle}' is already in use.")
      end
    end
  end
end