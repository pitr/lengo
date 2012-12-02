Idealog::Application.routes.draw do

  get "speech/tts"

  # authenticated :user do
    root :to => 'ideas#index'

    resources :ideas
  # end

  # root :to => "home#index"

  # devise_for :users

  # resources :users
end
