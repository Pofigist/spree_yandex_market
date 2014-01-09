module Spree
  module Admin
    class YandexMarketSettingsController < Spree::Admin::BaseController
      def edit
        @taxonomies = Spree::Taxonomy.limit(10)
      end

      def update
        Spree::YandexMarketConfig.set(params[:preferences])

        respond_to do |format|
          format.html {
            flash[:success] = t(:yandex_market_settings_updated)
            redirect_to edit_admin_yandex_market_settings_path
          }
        end
      end
      
      def taxonomy
        taxonomy = Taxonomy.find(params[:id])
        out = render_to_string(:partial => 'cats', :formats => :html, :layout => false, :locals => {:taxonomy => taxonomy})
        respond_to do |format|
          format.json {
            render :json => {html: out}
          }
        end
      end
      
      def export
        Thread.new { `rake yandex_market:export` }
        render text: t(:yandex_market_generation_started), status: 200
      end
    end
  end
end
