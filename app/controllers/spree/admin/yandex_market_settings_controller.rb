module Spree
  module Admin
    class WizardsController < Spree::Admin::BaseController

      def index
        @wizards=Spree::Wizard.order(:id)
      end

      def new
        @wizard=Spree::Wizard.new
      end

      def create
        if params[:wizard][:name].present?
          @wizard=Spree::Wizard.new(:name=>params[:wizard][:name])
          if @wizard.save
            @wizard.create_wizard_taxons(@wizard,params[:wizard][:wizard_taxon_ids])
            flash[:success]='Wizard был успешно создан'
          else
            flash[:notice]='Wizard не был создан'
          end
        else
          flash[:notice]='Wizard не был создан'
        end
        redirect_to main_app.admin_wizards_path
      end


      def edit
        @wizard=Spree::Wizard.find(params[:id])
        @wizard_taxons=@wizard.wizard_taxons
      end

      def update
        @wizard=Spree::Wizard.find(params[:id])
        if @wizard.update_attributes(:name=>params[:wizard][:name],:tags=>params[:wizard][:tags])
          flash[:success]='Wizard был успешно обновлен'
        else
          flash[:notice]='Wizard не был обновлен'
        end
        @wizard.edit_wizard_taxons(@wizard,params[:wizard][:wizard_taxon_ids])
        redirect_to main_app.admin_wizards_path
      end

      def destroy
        @wizard=Spree::Wizard.find(params[:id])
        @wizard.destroy
      end


      def search
        taxons_pre=Spree::Taxon.search(:id_in=>params[:ids].split(',')).result if params[:ids]
        @taxons=taxons_pre.map{|e| [id: e.id,name: e.pretty_name]}.flatten if taxons_pre.present?
        @taxons=Spree::Taxon.joins(:taxonomy).where("lower(spree_taxons.name) ILIKE lower('%#{params[:q][:name_cont]}%')").limit(10).map{|e| [id: e.id,name: e.pretty_name]}.flatten if !params[:ids]
        render :json=>@taxons.to_json
      end

    end
  end
end
