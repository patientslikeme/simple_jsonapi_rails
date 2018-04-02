Rails.application.routes.draw do
  resources :orders do
    jsonapi_to_many_relationship(:orders, :items)
  end
end
