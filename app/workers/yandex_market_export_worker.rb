class YandexMarketExportWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false,:queue => :export

  def perform
    YandexMarketExport.new
  end

end
