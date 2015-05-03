class SubscribersController < ApplicationController
  
  helper_method :subscriber
  
  attr_reader :subscriber
  
  def new
    set_subscriber
  end
  
  def create
    set_subscriber
    if subscriber.save
      render nothing: true, status: :created
      send_welcome_email
    else
      render nothing: true, status: :bad_request
    end
  end
  
  
  
  private
  

  def send_welcome_email
    EmailerJob.perform_later(Time.now.to_s)
  end  
  
  def subscriber_params
    if params[:subscriber]
      params.require(:subscriber).permit(:email)
    else
      {}
    end
  end
  
  def set_subscriber
    @subscriber = Subscriber.new(subscriber_params)
  end
  
end
