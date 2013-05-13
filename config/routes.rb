Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  namespace :admin do
    resource :yandex_market_settings, only: [:edit, :update]
    get "/yandex_market_settings/taxonomy/:id" => "yandex_market_settings#taxonomy"
    post "/yandex_market_settings/export" => "yandex_market_settings#export"
  end
end
