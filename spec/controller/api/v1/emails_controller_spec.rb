# spec/controllers/api/v1/emails_controller_spec.rb

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Api::V1::EmailsController, type: :controller do
  describe 'POST #create' do
    let(:valid_params) do
      {
        email: {
          to: 'x9ahn.test@inbox.testmail.app',
          to_name: 'x9ahn',
          subject: 'Test Email',
          text_content: 'This is a test email',
          html_content: '<p>This is a test email</p>'
        }
      }
    end

    let(:test_mail_response) do
      {
        "result" => "success",
        "message" => nil,
        "count" => 0,
        "limit" => 10,
        "offset" => 0,
        "emails" => []
      }
    end

    before do
      stub_request(:get, "https://api.testmail.app/api/json")
        .with(query: hash_including({
                                      "apikey" => "449ffa39-91f2-4732-af21-aab8db5eee38",
                                      "namespace" => "x9ahn",
                                      "pretty" => "true"
                                    }))
        .to_return(status: 200, body: test_mail_response.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    context 'when the email is sent successfully' do
      before do
        allow(Mailjet::Send).to receive(:create).and_return(double(success?: true))
      end

      it 'returns a success response and checks test mail server' do
        post :create, params: valid_params
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ 'message' => 'Email sent successfully' })

        # Verify that the test mail server was called
        expect(WebMock).to have_requested(:get, "https://api.testmail.app/api/json")
                             .with(query: hash_including({
                                                           "apikey" => "449ffa39-91f2-4732-af21-aab8db5eee38",
                                                           "namespace" => "x9ahn",
                                                           "pretty" => "true"
                                                         }))
      end
    end

    context 'when the email fails to send' do
      before do
        allow(Mailjet::Send).to receive(:create).and_return(double(success?: false))
      end

      it 'returns an error response' do
        post :create, params: valid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Failed to send email' })
      end
    end
  end
end