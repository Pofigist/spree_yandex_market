class YandexMarketExportWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false,:queue => :pricing

  def perform
    YandexMarketExport.new
  end

end
