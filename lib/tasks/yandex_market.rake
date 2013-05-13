namespace :yandex_market do
  desc %q{Export products into YandexMarket format}
  task :export => :environment do
    data = YandexMarketExport.new
    file = File.new(Rails.root.join('tmp', "market_#{Time.now.to_i}"), 'w')
    file.puts data.out
    File.rename file.path, Rails.root.join('public', Spree::YandexMarketConfig[:file_path]) if file.size > 30
  end
end