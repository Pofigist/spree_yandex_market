module Spree
  module Admin
    class YandexMarketSettingsController < Spree::Admin::BaseController
      def edit
        @taxonomies = Spree::Taxonomy.limit(10)
      end

      def taxonomies_search
          taxonomies_pre=Spree::Taxonomy.search(:id_eq => Spree::YandexMarketConfig[:cat_taxonomy_id]).result.first if params[:ids] == 'none'
          @taxonomies={id: taxonomies_pre.id,name: taxonomies_pre.name} if taxonomies_pre.present?
          @taxonomies=Spree::Taxonomy.where("lower(spree_taxonomies.name) ILIKE lower('%#{params[:q][:name_cont]}%')").limit(10).map{|e| [id: e.id,name: e.name]}.flatten if params[:ids] != 'none'
          render :json=>@taxonomies.to_json
      end

      def taxonomy_taxons
          @root = Spree::Taxonomy.find(params[:taxonomy_id]).try(:root)
          @taxons = Spree::Taxons.where("parent_id = #{@root.try(:id)}")
          render 'taxonomy_taxons'
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
