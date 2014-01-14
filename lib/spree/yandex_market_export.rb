#encoding: utf-8
require 'nokogiri'

class YandexMarketExport

    def initialize
        @file =  File.new(Rails.root.join('public', y(:file_path)), 'w:UTF-8')
        @file.truncate(0)
        @file.puts("<yml_catalog date=\"#{Time.now.strftime("%Y-%m-%d %H:%M")}\">")
        shop
        @file.puts("</yml_catalog>")
        @file.close
    end

    def shop
        @file.puts("<name>#{y(:shop_name)}</name>")
        @file.puts("<company>#{ y(:shop_company) }</company>")
        @file.puts("<url>#{Spree::Config.site_url}</url>")
        @file.puts("<platform>#{ "Spree" }</platform>")
        @file.puts("<version>#{ Spree.version}</version>")
        @file.puts("<agency>#{y(:shop_agency)}</agency>")
        @file.puts("<email>#{y(:shop_email)}</email>")
        currencies
        categories
        offers
        return 1
    end

    def currencies
        @file.puts("<currencies>")
        @file.puts("<currency id=\"#{Spree::Config[:currency]}\" rate=\"#{1}\"/>")
        @file.puts("</currencies>")
        return 1
    end

    def categories
        @file.puts("<categories>")
        Spree::Taxonomy.where("spree_taxonomies.id in (#{y(:cat_taxonomy_ids)})").each do |e|
            cats(e).each do |c|
                @file.puts("<category id=\"#{c.id}\" parentId=\"#{c.parent_id}\">#{replace_s(c.name)}</category>")
            end
        end
        @file.puts("</categories>")
        return 1
    end

    def offers
        @file.puts("<offers>")
        Spree::Product.select("distinct(spree_products.*)").joins(master: :prices).joins(:taxons).where("spree_prices.amount > 0 and spree_taxons.taxonomy_id in (#{y(:cat_taxonomy_ids)})").find_each(:batch_size => 100) do |p|
            @file.puts("<offer id=\"#{p.id}\" type=\"vendor.model\" available=\"true\">")
            category = p.taxons.where("spree_taxons.taxonomy_id in (#{y(:cat_taxonomy_ids)})").first
            @file.puts("<url>#{Spree::Config.site_url}/products/#{replace_s(p.permalink)}</url>")
            @file.puts("<price>#{p.price}</price>")
            @file.puts("<currencyId>#{Spree::Config[:currency]}</currencyId>")
            @file.puts("<categoryId>#{category.id}</categoryId>") if category.id
            p.images.first(10).each do |i|
                @file.puts("<picture>#{Spree::Config.site_url}#{i.attachment.url(:original)}</picture>")
            end
            @file.puts("<store>#{y(:store)}</store>")
            @file.puts("<pickup>#{y(:pickup)}</pickup>")
            @file.puts("<delivery>#{y(:delivery)}</delivery>")
            @file.puts("<typePrefix>#{replace_s(p.name)}</typePrefix>")
            @file.puts("<vendor>#{replace_s(p.property(vendor_prop.name))}</vendor>") if vendor_prop
            @file.puts("<model>#{replace_s(p.property(model_prop.name))}</model>") if model_prop
            @file.puts("<description>#{replace_s(p.description)}</description>")
            @file.puts("<adult>#{y(:adult)}</adult>") if y(:adult)
            @file.puts("<age>#{y(:age)}</age>") if y(:age) != 0
            @file.puts("</offer>")
        end
        @file.puts("</offers>")
        return 1
    end

    def cats(taxonomy)
        taxonomy.root.self_and_descendants
    end
    
    def replace_s(str)
        str.gsub('&','&amp;').gsub('<','').gsub('>','').gsub('"','&quot;') if str.class == String
    end

    def products
        ps = Spree::Product.select("distinct(spree_products.*)").joins(master: :prices).joins(:taxons).where("spree_prices.amount > 0 and spree_taxons.taxonomy_id in (#{y(:cat_taxonomy_ids)})")
        ps
    end

    def model_prop
        Spree::Property.find(y :model_prop)
    end

    def vendor_prop
        Spree::Property.find(y :vendor_prop)
    end

    private
    def y(term)
        Spree::YandexMarketConfig[term]
    end

end
