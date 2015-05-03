class EmailerJob < ActiveJob::Base
  
  require 'gibbon'
  
  
  delegate :info, :warn, to: :logger
  
  
  def perform(email)
    begin
      gibbon.lists.subscribe({
        id: secrets.mailchimp_list_id, 
        email: { email: email }, 
        double_optin: true
        })
        info("Successfully added subscriber: #{email}")
    rescue Gibbon::MailChimpError => e
      warn("Error: #{e.message}")
    end
  end


  private


  def gibbon
    @gibbon ||= Gibbon::API.new(secrets.mailchimp_api_key)
  end

  def secrets
    Rails.application.secrets
  end

  def logger
    Logger.new(Rails.root.join("log", "mailchimp.log"))
  end

end
