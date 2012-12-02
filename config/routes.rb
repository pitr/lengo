Idealog::Application.routes.draw do

  get "speech/tts"

  root :to => 'ideas#index'

  resources :ideas
end
