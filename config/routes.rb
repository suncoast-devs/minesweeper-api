Rails.application.routes.draw do
  resources :games do
    member do
      post :check
      post :flag
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
