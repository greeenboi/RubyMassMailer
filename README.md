# RubyMassMailer

RubyMassMailer is a Rails API-only application designed to provide a flexible platform for sending mass transactional emails. Whether you're sending order confirmations, password resets, or any other type of email, RubyMassMailer makes it easy to manage and send your emails.

## Features

- **API-Only**: Lightweight and efficient API-only Rails application.
- **Mass Email Sending**: Easily send transactional emails to multiple recipients.
- **Customizable Templates**: Use customizable email templates to fit your branding and message.
- **Queue Processing**: Background job processing for handling email queues.

## Getting Started

### Prerequisites

- Ruby 3.0
- Rails 6.0 or higher

### Installation

1. Clone the repository:

    ```bash
    git clone https://github.com/greeenboi/RubyMassMailer.git
    cd RubyMassMailer
    ```

2. Install the dependencies:

    ```bash
    bundle install
    ```
3. Create and Fill the Enviroment file `.env.example` -> `.env`

4. Start the server:

    ```bash
    rails s
    ```

### Configuration

Within `./config/initializers/mailjet` adjust the api `v3.1` or `v3.0` depending on whether you want to send batch mails or not (check your mailjet config)

### Mailer Config
Configure the mailer settings in config/environments/production.rb:
```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: ENV['SMTP_ADDRESS'],
  port: ENV['SMTP_PORT'],
  user_name: ENV['SMTP_USER_NAME'],
  password: ENV['SMTP_PASSWORD'],
  authentication: 'plain',
  enable_starttls_auto: true
}
```

### Usage
Sending Emails
To send an email, make a POST request to the /api/v1/emails endpoint.

> Sample JS script

```js
const fs = require('fs');
const path = require('path');
const axios = require('axios');
const FormData = require('form-data');

const API_URL = 'http://localhost:3000/api/v1/emails'; 
const RECIPIENT_EMAIL = 'coolman@email.com'; // Replace with your test recipient email
const ATTACHMENT_PATH = './yummy.jpg'; // Replace with the path to a test attachment file

async function sendTestEmail() {
  try {
    const formData = new FormData();
    formData.append('email[to]', RECIPIENT_EMAIL);
    formData.append('email[to_name]', 'Test Recipient');
    formData.append('email[subject]', 'Test Email from Demo Server');
    formData.append('email[text_content]', 'This is a test email sent from our demo server.');
    formData.append('email[html_content]', '<h1>Test Email</h1><p>This is a <strong>test email</strong> sent from our demo server.</p>');

    // Add attachment if the file exists
    if (fs.existsSync(ATTACHMENT_PATH)) {
      const attachment = fs.createReadStream(ATTACHMENT_PATH);
      formData.append('email[attachments][]', attachment, path.basename(ATTACHMENT_PATH));
    }

    const response = await axios.post(API_URL, formData, {
      headers: {
        ...formData.getHeaders(),
      },
    });

    console.log('Response Status:', response.status);
    console.log('Response Data:', response.data);
  } catch (error) {
    console.error('Error sending email:', error.response ? error.response.data : error.message);
  }
}

sendTestEmail();
```

### Contributing
  We will open this soon.

### License
  This project is licensed under the MIT License - see the LICENSE file for details.
