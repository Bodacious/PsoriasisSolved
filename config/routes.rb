Rails.application.routes.draw do
  
  resources :subscribers, only: [:create]

  root to: 'subscribers#new'
end
