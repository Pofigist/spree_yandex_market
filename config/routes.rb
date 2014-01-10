Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  namespace :admin do
    resource :yandex_market_settings, only: [:edit, :update]
    get "/yandex_market_settings/taxonomy/:id" => "yandex_market_settings#taxonomy"
    post "/yandex_market_settings/export" => "yandex_market_settings#export"
    get "/yandex_market_settings/taxonomies/search" => "yandex_market_settings#taxonomies_search"
    get "/yandex_market_settings/taxonomies/taxons" => "yandex_market_settings#taxonomy_taxons"
    get "/yandex_market_settings/properties/find" => "yandex_market_settings#properties_find"
  end
end
