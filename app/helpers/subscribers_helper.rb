module SubscribersHelper
  
  def mailchimp_subscribe_url
    mailchimp_params = { u: "1d5686bbf51d8682fecc3478b", id: ENV['MAILCHIMP_LIST_ID'] }
    "//psoriasissolved.us10.list-manage.com/subscribe/post?#{mailchimp_params.to_param}"
  end
end
