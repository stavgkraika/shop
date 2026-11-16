Rails.application.routes.draw do
  resources :products
  resource :cart, only: [:show, :destroy]
  resources :cart_items, only: [:create, :update, :destroy]
  devise_for :users, controllers: {
    registrations: 'registrations'
  }
  root 'products#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
