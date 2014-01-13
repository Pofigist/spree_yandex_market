namespace :yandex_market do
  desc %q{Export products into YandexMarket format}
  task :export => :environment do
      YandexMarketExport.new
  end
end
