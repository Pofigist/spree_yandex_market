module Spree
  module Admin
    class YandexMarketSettingsController < Spree::Admin::BaseController
      def edit
      end

      def taxonomies_search
        taxonomies_pre=Spree::Taxonomy.where("id in (#{Spree::YandexMarketConfig[:cat_taxonomy_ids]})") if params[:ids] == 'none'
        @taxonomies=taxonomies_pre.map{|e| [id: e.id,name: e.name]}.flatten if taxonomies_pre.present?
        @taxonomies=Spree::Taxonomy.where("lower(spree_taxonomies.name) ILIKE lower('%#{params[:q][:name_cont]}%')").limit(10).map{|e| [id: e.id,name: e.name]}.flatten if params[:ids] != 'none'
        render :json=>@taxonomies.to_json
      end

      def taxonomy_taxons
          @root = Spree::Taxonomy.find(params[:taxonomy_id]).try(:root)
          @taxons = Spree::Taxon.where("parent_id = #{@root.try(:id)}")
          render 'taxonomy_taxons'
      end

      def properties_find
        if params[:ids] == 'vendor' || params[:ids] == 'model'
          @property=Spree::Property.find(Spree::YandexMarketConfig[:model_prop]) if params[:ids] == 'model'
          @property=Spree::Property.find(Spree::YandexMarketConfig[:vendor_prop]) if params[:ids] == 'vendor'
          @property={id: @property.id ,name: @property.name}
          render :json=>@property.to_json
        else
          @properties=Spree::Property.where("lower(spree_properties.name) ILIKE lower('%#{params[:q][:name_cont]}%')").limit(10).map{|e| [id: e.id,name: e.name]}.flatten.uniq
          render :json=>@properties.to_json
        end
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
        if Sidekiq::Workers.new.size == 0
          Thread.new { `rake yandex_market:export` }
          render text: t(:yandex_market_generation_started), status: 200
        end
      end
    end
  end
end
