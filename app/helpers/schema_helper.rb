# encoding: utf-8

# Helper methods for generating Schema.org markup
Rozario::App.helpers do
  
  # Helper method to check if value is blank (nil, empty, or whitespace)
  def blank?(value)
    value.nil? || (value.respond_to?(:empty?) && value.empty?) || (value.respond_to?(:strip) && value.strip.empty?)
  end
  
  # Helper method to check if value is present (not blank)
  def present?(value)
    !blank?(value)
  end
  
  # Generates Schema.org ImageObject JSON-LD script tag
  def generate_image_schema(image_url, options = {})
    schema_data = {
      "@context" => "http://schema.org",
      "@type" => "ImageObject",
      "contentUrl" => image_url
    }
    
    # Add optional fields if provided
    schema_data["name"] = options[:name] if options[:name]
    schema_data["description"] = options[:description] if options[:description] 
    schema_data["datePublished"] = options[:date_published] if options[:date_published]
    schema_data["width"] = options[:width] if options[:width]
    schema_data["height"] = options[:height] if options[:height]
    schema_data["author"] = options[:author] || "Rozario Flowers"
    
    content_tag(:script, 
                JSON.pretty_generate(schema_data).html_safe, 
                type: "application/ld+json")
  end
  
  # Generate schema for product images
  def product_image_schema(product, mobile = false)
    return "" unless product.respond_to?(:thumb_image)
    
    begin
      image_url = full_image_url(product.thumb_image(mobile))
      return "" if blank?(image_url)
      
      options = {
        name: product.respond_to?(:header) ? product.header : "Product Image",
        description: (product.respond_to?(:alt) && present?(product.alt)) ? product.alt : (product.respond_to?(:header) ? product.header : "Product Image"),
        date_published: product.respond_to?(:created_at) ? product.created_at.strftime("%Y-%m-%d") : Date.current.strftime("%Y-%m-%d"),
        author: "Rozario Flowers"
      }
      
      # Try to get image dimensions if available 
      # Note: dimensions are hardcoded as requested, 
      # but could be extracted from actual image files
      if mobile
        options[:width] = "650"
        options[:height] = "650"
      else
        options[:width] = "1315"
        options[:height] = "650"
      end
      
      generate_image_schema(image_url, options)
    rescue => e
      # Log error but don't break the page
      ""
    end
  end
  
  # Generate schema for album photos
  def photo_image_schema(photo)
    return "" unless photo.respond_to?(:image)
    
    begin
      image_url = full_image_url(photo.image)
      return "" if blank?(image_url)
      
      options = {
        name: photo.respond_to?(:title) ? photo.title : "Photo",
        description: photo.respond_to?(:title) ? photo.title : "Photo",
        date_published: photo.respond_to?(:created_at) ? photo.created_at.strftime("%Y-%m-%d") : Date.current.strftime("%Y-%m-%d"),
        author: "Rozario Flowers"
      }
      
      generate_image_schema(image_url, options)
    rescue => e
      # Log error but don't break the page
      ""
    end
  end
  
  # Generate schema for smile/review images with safe handling
  def smile_image_schema(smile, alt_text = nil)
    return "" unless smile && smile.respond_to?(:images_identifier) && present?(smile.images_identifier)
    
    begin
      image_path = "/uploads/smiles/#{smile.images_identifier}"
      image_url = full_image_url(image_path)
      return "" if blank?(image_url)
      
      # Use provided alt_text or construct safe fallback
      name = alt_text || (smile.respond_to?(:title) && present?(smile.title) ? smile.title : "Отзыв покупателя")
      description = alt_text || name
      
      options = {
        name: name,
        description: description,
        date_published: (smile.respond_to?(:created_at) && smile.created_at) ? smile.created_at.strftime("%Y-%m-%d") : Date.current.strftime("%Y-%m-%d"),
        author: "Rozario Flowers"
      }
      
      generate_image_schema(image_url, options)
    rescue => e
      # Log error but don't break the page
      ""
    end
  end
  
  # Generate schema for category images
  def category_image_schema(category)
    return "" unless category.respond_to?(:image)
    
    begin
      image_url = full_image_url(category.image)
      return "" if blank?(image_url)
      
      options = {
        name: category.respond_to?(:title) ? category.title : "Категория товаров",
        description: category.respond_to?(:title) ? category.title : "Категория товаров",
        date_published: category.respond_to?(:created_at) ? category.created_at.strftime("%Y-%m-%d") : Date.current.strftime("%Y-%m-%d"),
        author: "Rozario Flowers"
      }
      
      generate_image_schema(image_url, options)
    rescue => e
      # Log error but don't break the page
      ""
    end
  end
  
  # Generate schema for product modal images (with Angular image URL)
  def product_modal_image_schema(product, angular_image_var = nil)
    return "" unless product
    
    begin
      # For modal images, we might use Angular variables or product image
      if angular_image_var
        # Use the Angular variable as-is for contentUrl - it will be resolved on client side
        image_url = "{{ #{angular_image_var} }}"
      else
        image_url = full_image_url(product.respond_to?(:thumb_image) ? product.thumb_image(false) : "")
        return "" if blank?(image_url)
      end
      
      options = {
        name: product.respond_to?(:header) ? product.header : "Product Image",
        description: (product.respond_to?(:alt) && present?(product.alt)) ? product.alt : (product.respond_to?(:header) ? product.header : "Product Image"),
        date_published: product.respond_to?(:created_at) ? product.created_at.strftime("%Y-%m-%d") : Date.current.strftime("%Y-%m-%d"),
        author: "Rozario Flowers"
      }
      
      # For desktop images in modal
      options[:width] = "900"
      options[:height] = "650"
      
      generate_image_schema(image_url, options)
    rescue => e
      # Log error but don't break the page
      ""
    end
  end
  
  # Generate schema for complex product images (from perekrestok template)
  def complex_product_image_schema(product, image_url)
    return "" unless product && present?(image_url)
    
    begin
      full_url = full_image_url(image_url)
      return "" if blank?(full_url)
      
      options = {
        name: product.respond_to?(:header) ? product.header : "Product Image",
        description: (product.respond_to?(:alt) && present?(product.alt)) ? product.alt : (product.respond_to?(:header) ? product.header : "Product Image"),
        date_published: product.respond_to?(:created_at) ? product.created_at.strftime("%Y-%m-%d") : Date.current.strftime("%Y-%m-%d"),
        author: "Rozario Flowers"
      }
      
      # Standard product image dimensions
      options[:width] = "650"
      options[:height] = "650"
      
      generate_image_schema(full_url, options)
    rescue => e
      # Log error but don't break the page
      ""
    end
  end
  
  # Generate schema for news/article images
  def news_image_schema(news)
    return "" unless news.respond_to?(:image)
    
    begin
      image_url = full_image_url(news.image)
      return "" if blank?(image_url)
      
      options = {
        name: news.respond_to?(:title) ? news.title : "Новость",
        description: news.respond_to?(:title) ? news.title : "Новость",
        date_published: news.respond_to?(:created_at) ? news.created_at.strftime("%Y-%m-%d") : Date.current.strftime("%Y-%m-%d"),
        author: "Rozario Flowers"
      }
      
      generate_image_schema(image_url, options)
    rescue => e
      # Log error but don't break the page
      ""
    end
  end
  
  # Generate schema for slideshow slides
  def slide_image_schema(slide)
    return "" unless slide.respond_to?(:image)
    
    begin
      image_url = full_image_url(slide.image)
      return "" if blank?(image_url)
      
      options = {
        name: (slide.respond_to?(:text) && present?(slide.text)) ? slide.text : "Slideshow Image",
        description: (slide.respond_to?(:text) && present?(slide.text)) ? slide.text : "Slideshow Image",
        date_published: slide.respond_to?(:created_at) ? slide.created_at.strftime("%Y-%m-%d") : Date.current.strftime("%Y-%m-%d"),
        author: "Rozario Flowers"
      }
      
      generate_image_schema(image_url, options)
    rescue => e
      # Log error but don't break the page
      ""
    end
  end
  
  private
  
  # Convert relative image URL to full URL
  def full_image_url(image_path)
    return "" if image_path.nil? || (image_path.respond_to?(:empty?) && image_path.empty?)
    
    begin
      image_path_str = image_path.to_s
      return "" if image_path_str.empty?
      
      # If it's already a full URL, return as is
      return image_path_str if image_path_str.start_with?('http')
      
      # Otherwise, construct full URL
      subdomain_url = (@subdomain && @subdomain.respond_to?(:url)) ? @subdomain.url : 'rozarioflowers'
      base_url = "https://#{subdomain_url}.#{CURRENT_DOMAIN}"
      image_path_str.start_with?('/') ? "#{base_url}#{image_path_str}" : "#{base_url}/#{image_path_str}"
    rescue => e
      ""
    end
  end
end
