#encoding: utf-8
require 'nokogiri'

class YandexMarketExport
  
  def initialize
    @cat_taxonomy = Spree::Taxonomy.find(y :cat_taxonomy_id)
    @builder = Nokogiri::XML::Builder.new encoding: 'UTF-8' do |xml|
      xml.doc.create_internal_subset('yml_catalog', nil, 'shops.dtd')
      xml.yml_catalog(date: Time.now.strftime("%Y-%m-%d %H:%M")) {
        shop xml
      }
    end
  end
  
  def shop(xml)
    xml.shop do |s|
      s.name        y(:shop_name)
      s.company     y(:shop_company)
      s.url         Spree::Config.site_url
      s.platform    "Spree"
      s.version     Spree.version
      s.agency      y(:shop_agency)
      s.email       y(:shop_email)
      
      currencies s
      categories s
      offers s
    end
  end
  
  def currencies(xml)
    xml.currencies {
      xml.currency id: Spree::Config[:currency], rate: 1
    }
  end
  
  def categories(xml)
    xml.categories {
      cats.each do |c|
        params = {id: c.id}
        params[:parentId] = c.parent_id if c.parent != @cat_taxonomy.root
        xml.category c.name, params
      end
    }
  end
  
  def offers(xml)
    xml.offers {
      products.each do |p|
        xml.offer id: p.id, type: "vendor.model", available: true do |o|
          category = p.taxons.where(taxonomy_id: @cat_taxonomy.id).first
          o.url         "#{Spree::Config.site_url}/products/#{p.permalink}"
          o.price       p.price.to_i
          o.currencyId  Spree::Config[:currency]
          o.categoryId  category.id if category
          p.images.first(10).each { |i| o.picture "#{Spree::Config.site_url}#{i.attachment.url(:original)}" }
          o.store       y(:store)
          o.pickup      y(:pickup)
          o.delivery    y(:delivery)
          o.typePrefix  p.name
          o.vendor      p.property(vendor_prop.name) if vendor_prop
          o.model_      p.property(model_prop.name) if model_prop
          o.description p.description
          o.adult       y(:adult) if y(:adult)
          o.age         y(:age) unless y(:age) == 0
          properties.each do |prop|
            prod_prop = p.property(prop.name)
            o.param prod_prop, name: prop.presentation unless prop.id == y(:vendor_prop) || prop.id == y(:model_prop)
          end
          p.option_types.each do |opt_type|
            opt_values = p.variants.map {|v| v.option_value(opt_type.name) }
            o.param opt_values.uniq.sort.join(','), name: opt_type.presentation
          end
        end
      end
    }
  end
  
  def cats
    if y(:cat_filtered)
      @cat_taxonomy.taxons.where(id: y(:cat_list).split(',').map(&:to_i)).map(&:self_and_descendants).flatten
    else 
      @cat_taxonomy.root.descendants
    end
  end
  
  def products
    ps = Spree::Product.active
    ps
  end
  
  def model_prop
    Spree::Property.find(y :model_prop)
  end
  
  def vendor_prop
    Spree::Property.find(y :vendor_prop)
  end
  
  def properties
    Spree::Property.all
  end
  
  def out
    @builder.to_xml
  end
  
  private
  def y(term)
    Spree::YandexMarketConfig[term]
  end
  
end
