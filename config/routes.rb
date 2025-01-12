Rails.application.routes.draw do
  get "admin" => "admin#index"
  controller :sessions do
    get  "login" => :new
    post "login" => :create
    delete "logout" => :destroy
  end
  get "sessions/create"
  get "sessions/destroy"

  resources :users
  resources :products

  scope "(:locale)" do
    resources :orders
    resources :line_items
    resources :carts
    root "store#index", as: "store_index", via: :all
  end
end
