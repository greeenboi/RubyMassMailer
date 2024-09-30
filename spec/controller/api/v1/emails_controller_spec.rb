# spec/controllers/api/v1/emails_controller_spec.rb
require 'rails_helper'

RSpec.describe Api::V1::EmailsController, type: :controller do
  describe 'POST #create' do
    let(:valid_attributes) do
      {
        email: {
          subject: 'Test Email',
          text_content: 'This is a test email.',
          html_content: '<p>This is a test email.</p>',
          recipients: [
            { email: 'recipient1@example.com', name: 'Recipient One' },
            { email: 'recipient2@example.com', name: 'Recipient Two' }
          ],
          attachments: [
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'test_attachment1.pdf'), 'application/pdf'),
            fixture_file_upload(Rails.root.join('spec', 'fixtures', 'test_attachment2.txt'), 'text/plain')
          ]
        }
      }
    end

    it 'sends an email' do
      expect {
        post :create, params: valid_attributes
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'returns a success response' do
      post :create, params: valid_attributes
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include('message' => 'Email sent successfully')
    end

    it 'sends to multiple recipients' do
      post :create, params: valid_attributes
      email = ActionMailer::Base.deliveries.last
      expect(email.to).to contain_exactly('Recipient One <recipient1@example.com>', 'Recipient Two <recipient2@example.com>')
    end

    it 'includes attachments' do
      post :create, params: valid_attributes
      email = ActionMailer::Base.deliveries.last
      expect(email.attachments.size).to eq(2)
      expect(email.attachments.first.filename).to eq('test_attachment1.pdf')
      expect(email.attachments.last.filename).to eq('test_attachment2.txt')
    end

    context 'when the email fails to send' do
      before do
        allow_any_instance_of(Mail::Message).to receive(:deliver_now!).and_raise(StandardError.new("Sending failed"))
      end

      it 'returns an error response' do
        post :create, params: valid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include('error' => 'Failed to send email')
      end
    end
  end
end