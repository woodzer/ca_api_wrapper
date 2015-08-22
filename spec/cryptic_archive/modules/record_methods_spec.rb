require "spec_helper"

describe CrypticArchive::RecordMethods do
  let(:record_id) {
    SecureRandom.uuid
  }
  let(:session_id) {
    SecureRandom.uuid
  }
  let(:title) {
    "Test Record"
  }
  let(:type) {
    "account"
  }
  subject {
    CrypticArchive::Session.new
  }
  let(:content) {
    {url: "https://www.fake.com",
     user_name: "fake.email@nowhere.com"}
  }
  let(:full_content) {
    {title: title, type: type}.merge(content)
  }


  #-----------------------------------------------------------------------------
  # #create_record()
  #-----------------------------------------------------------------------------
  describe "#create_record()" do
    describe "when the user has an established session" do
      before do
        subject.session_id = session_id
      end

      describe "and the server responds with success" do
        let(:response) {
          {succcess: true,
           record: {id: SecureRandom.uuid, tags: [], title: title, type: type}}
        }

        it "makes a post request to the REST API server and returns success" do
          expect(subject).to receive(:post).with("/api/v1/records",
                                                 {content: full_content,
                                                  session_id: session_id}).and_return(response.to_json).once
          output = subject.create_record(title, type, content)
          expect(output).to eq(JSON.parse(response.to_json))
        end
      end

      describe "and the server responds with an error" do
        let(:response) {
          {success: false,
           error: {code: "an.error.code", message: "An error occurred."}}
        }

        before do
          stub_request(:post, "https://www.crypticarchive.com/api/v1/records").
            with(:body => {"content"=>{"title"=>"Test Record", "type"=>"account", "url"=>"https://www.fake.com", "user_name"=>"fake.email@nowhere.com"}, "session_id"=>session_id}).
            to_return(:status => 400, :body => response.to_json, :headers => {})
        end

        it "raises an exception" do
          expect {
            subject.create_record(title, type, content)
          }.to raise_exception(CrypticArchive::CAError, "An error occurred.")
        end
      end
    end

    describe "when the user hasn't yet established a session" do
      it "raises an exception" do
        expect {
          subject.create_record(title, type, content)
        }.to raise_exception(CrypticArchive::CAError, "You are not connected to the server.")
      end
    end
  end

  #-----------------------------------------------------------------------------
  # #delete_record()
  #-----------------------------------------------------------------------------
  describe "#delete_record()" do
    describe "when the user has an established session" do
      before do
        subject.session_id = session_id
      end

      describe "and the server responds with success" do
        let(:response) {
          {succcess: true}
        }

        it "makes a delete request to the REST API server and returns success" do
          expect(subject).to receive(:delete).with("/api/v1/records/#{record_id}",
                                                   {session_id: session_id}).and_return(response.to_json).once
          output = subject.delete_record(record_id)
          expect(output).to eq(JSON.parse(response.to_json))
        end
      end

      describe "and the server responds with an error" do
        let(:response) {
          {success: false,
           error: {code: "an.error.code", message: "An error occurred."}}
        }

        before do
          stub_request(:delete, "https://www.crypticarchive.com/api/v1/records/#{record_id}").
            to_return(:status => 400, :body => response.to_json, :headers => {})
        end

        it "raises an exception" do
          expect {
            subject.delete_record(record_id)
          }.to raise_exception(CrypticArchive::CAError, "An error occurred.")
        end
      end
    end

    describe "when the user hasn't yet established a session" do
      it "raises an exception" do
        expect {
          subject.delete_record(record_id)
        }.to raise_exception(CrypticArchive::CAError, "You are not connected to the server.")
      end
    end
  end

  #-----------------------------------------------------------------------------
  # #get_record()
  #-----------------------------------------------------------------------------
  describe "#get_record()" do
    describe "when the user has an established session" do
      before do
        subject.session_id = session_id
      end

      describe "and the server responds with success" do
        let(:response) {
          {succcess: true,
           record: {id: record_id,
                    title: title,
                    type:  type,
                    content: full_content}}
        }

        it "makes a delete request to the REST API server and returns success" do
          expect(subject).to receive(:get).with("/api/v1/records/#{record_id}",
                                                {session_id: session_id}).and_return(response.to_json).once
          output = subject.get_record(record_id)
          expect(output).to eq(JSON.parse(response[:record].to_json))
        end
      end

      describe "and the server responds with an error" do
        let(:response) {
          {success: false,
           error: {code: "an.error.code", message: "An error occurred."}}
        }

        before do
          stub_request(:get, "https://www.crypticarchive.com/api/v1/records/#{record_id}?session_id=#{session_id}").
            to_return(:status => 400, :body => response.to_json, :headers => {})
        end

        it "raises an exception" do
          expect {
            subject.get_record(record_id)
          }.to raise_exception(CrypticArchive::CAError, "An error occurred.")
        end
      end
    end

    describe "when the user hasn't yet established a session" do
      it "raises an exception" do
        expect {
          subject.get_record(record_id)
        }.to raise_exception(CrypticArchive::CAError, "You are not connected to the server.")
      end
    end
  end

  #-----------------------------------------------------------------------------
  # #list_records()
  #-----------------------------------------------------------------------------
  describe "#list_records()" do
    let(:records) {
      [{id: SecureRandom.uuid, tags: [], title: "Record 1", type: "account"},
       {id: SecureRandom.uuid, tags: [], title: "Record 2", type: "account"},
       {id: SecureRandom.uuid, tags: [], title: "Record 3", type: "account"}]
    }

    describe "when the user has an established session" do
      before do
        subject.session_id = session_id
      end

      describe "and the server responds with success" do
        let(:response) {
          {succcess: true, records: records}
        }

        it "makes a get request to the REST API server and returns success" do
          expect(subject).to receive(:get).with("/api/v1/records",
                                                {session_id: session_id}).and_return(response.to_json).once
          output = subject.list_records
          expect(output).to eq(JSON.parse(response[:records].to_json))
        end
      end

      describe "and the server responds with an error" do
        let(:response) {
          {success: false,
           error: {code: "an.error.code", message: "An error occurred."}}
        }

        before do
          stub_request(:get, "https://www.crypticarchive.com/api/v1/records?session_id=#{session_id}").
            to_return(:status => 400, :body => response.to_json, :headers => {})
        end

        it "raises an exception" do
          expect {
            subject.list_records
          }.to raise_exception(CrypticArchive::CAError, "An error occurred.")
        end
      end
    end

    describe "when the user hasn't yet established a session" do
      it "raises an exception" do
        expect {
          subject.list_records
        }.to raise_exception(CrypticArchive::CAError, "You are not connected to the server.")
      end
    end
  end

  #-----------------------------------------------------------------------------
  # #update_record()
  #-----------------------------------------------------------------------------
  describe "#update_record()" do
    describe "when the user has an established session" do
      before do
        subject.session_id = session_id
      end

      describe "and the server responds with success" do
        let(:response) {
          {succcess: true,
           record: {id: record_id, tags: [], title: title, type: type}}
        }

        it "makes a get request to the REST API server and returns success" do
          expect(subject).to receive(:put).with("/api/v1/records/#{record_id}",
                                                {content: content,
                                                 session_id: session_id}).and_return(response.to_json).once
          output = subject.update_record(record_id, content)
          expect(output).to eq(JSON.parse(response.to_json))
        end
      end

      describe "and the server responds with an error" do
        let(:response) {
          {success: false,
           error: {code: "an.error.code", message: "An error occurred."}}
        }

        before do
          stub_request(:put, "https://www.crypticarchive.com/api/v1/records/#{record_id}").
            to_return(:status => 400, :body => response.to_json, :headers => {})
        end

        it "raises an exception" do
          expect {
            subject.update_record(record_id, content)
          }.to raise_exception(CrypticArchive::CAError, "An error occurred.")
        end
      end
    end

    describe "when the user hasn't yet established a session" do
      it "raises an exception" do
        expect {
          subject.update_record(record_id, content)
        }.to raise_exception(CrypticArchive::CAError, "You are not connected to the server.")
      end
    end
  end
end
