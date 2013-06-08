module Spree
  Product.class_eval do
    def to_param
      permalink.present? ? permalink : (permalink_was || name.to_s.to_url.parameterize)
    end
  end
end