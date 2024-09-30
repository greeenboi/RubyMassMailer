class Api::V1::EmailsController < ApplicationController

  def create
    result = send_email
    if result.success?
      render json: { message: 'Email sent successfully' }, status: :ok
    else
      render json: { error: 'Failed to send email' }, status: :unprocessable_entity
    end
  end

  private

  def send_email
    Mailjet::Send.create(messages: [{
      'From' => {
        'Email' => ENV['MAILJET_DEFAULT_MAIL'],
        'Name' => ENV['MAILJET_DEFAULT_NAME']
      },
      'To' => [
        {
          'Email' => email_params[:to],
          'Name' => email_params[:to_name]
        }
      ],
      'Subject' => email_params[:subject],
      'TextPart' => email_params[:text_content],
      'HTMLPart' => email_params[:html_content],
      'Attachments' => attachments
    }])
  end

  def email_params
    params.require(:email).permit(:to, :to_name, :subject, :text_content, :html_content, attachments: [])
  end

  def attachments
    return [] unless email_params[:attachments].present?

    email_params[:attachments].map do |attachment|
      {
        'ContentType' => attachment.content_type,
        'Filename' => attachment.original_filename,
        'Base64Content' => Base64.encode64(attachment.read)
      }
    end
  end
end


