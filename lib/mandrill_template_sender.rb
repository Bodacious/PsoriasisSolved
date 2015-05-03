# We're using Mandrill to send outgoing emails.
# Email requests should be handled asynchronously to provide a speedy and slick
# experience for the User
#
# Example:
#   email = MandrillTemplateSender.new(@recipient, :notification, { content: "Hello!" }
class MandrillTemplateSender
  
  require 'mandrill'
  
  delegate :debug, :info, :warn, to: :logger

  # The recipient of the email
  attr_reader :recipient
  
  attr_reader :template_slug
  
  attr_reader :contents_hash
  
  attr_reader :email_name
  
  EMAIL_NAME_TO_TEMPLATE_SLUG_MAPPING = {
    :confirmation => "message-received-confirmation",
    :notification => "message-received-notification",
  }
    
  # Instantiate a new MandrillTemplateSender object ready to be sent asynchronously
  #
  # recipient      - A recipient object to send the email to
  # email_name     - A String that represents the email name. Think of these as the mailer
  #                  methods that you WOULD have called if we were using ActionMailer.
  # contents_hash  - A Hash of options to be passed to the Mandrill template.
  #
  # Returns a new MandrillEmail object
  def initialize(recipient, email_name, contents_hash)
    @recipient     = recipient
    @email_name    = email_name
    @template_slug = EMAIL_NAME_TO_TEMPLATE_SLUG_MAPPING[email_name.to_sym]
    @contents_hash = contents_hash
  end
    
  # A Mandrill::API object, provided by the mandrill-api gem
  def api
    @api ||= Mandrill::API.new(Rails.application.secrets.mandrill_api_key)
  end
  
  # Send the email to the recipient and log the response from Mandrill's API
  def send_template
    if Rails.env.production? or Rails.env.staging? or Rails.env.development?
      info("Sending #{template_slug} to #{recipient.email}")
      response = api.messages.send_template(template_slug, template_contents, message_hash)
      info response.flatten.first
    end
  end
  
  # The template_contents JSON object as a Ruby Array of Hashes
  #
  # Example: 
  #   # When @contents_hash = {:first_name => 'Gavin', :age => 27 }
  #   # Output looks like:
  #   [{"name": "first_name", "content": "Gavin"}, {"name": "age", "content": 27}]
  #
  # Returns an Array of Hashes
  def template_contents
    @template_contents ||= begin
      _template_contents = []
      contents_hash.each do |key, value|
        _template_contents << {"name" => key.to_s, "content" => value}
      end
      _template_contents
    end
  end


  private
  
  
  # Private: A custom logger for tracking Mandrill API calls
  def logger
    @logger ||= Logger.new(Rails.root.join('log', "mandrill-api.log"))
  end
  
  # Private: A Hash of default Mandrill API settings for the "message" node.
  def message_hash
    {
      "merge_language"    => "handlebars",
      "global_merge_vars" => template_contents,
      # Name of sender
      "from_name"         => "Psoriasis Solved", 
      # Create a .txt version of the mail for multipart
      "auto_text"         => true,
      # Track the opens in Mandrill
      "track_opens"       => true,
      # Track the clicks in Mandrill
      "track_clicks"      => true,
      # Mark email as important
      "important"         => false,
      # Email address to send from
      "from_email"        => 'gavin@psoriasissolved.com',
      "tags"              => [ email_name, Rails.env ],
      "to"           => [{ "email" => recipient.email }],
    }
  end
  
end