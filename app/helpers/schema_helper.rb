# encoding: utf-8

# Helper methods for generating Schema.org markup
Rozario::App.helpers do
  
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
                JSON.pretty_generate(schema_data), 
                type: "application/ld+json")
  end
  
  # Generate schema for product images
  def product_image_schema(product, mobile = false)
    image_url = full_image_url(product.thumb_image(mobile))
    
    options = {
      name: product.header,
      description: product.alt || product.header,
      date_published: product.created_at.strftime("%Y-%m-%d"),
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
  end
  
  # Generate schema for album photos
  def photo_image_schema(photo)
    image_url = full_image_url(photo.image)
    
    options = {
      name: photo.title,
      description: photo.title,
      date_published: photo.created_at.strftime("%Y-%m-%d"),
      author: "Rozario Flowers"
    }
    
    generate_image_schema(image_url, options)
  end
  
  # Generate schema for slideshow slides
  def slide_image_schema(slide)
    image_url = full_image_url(slide.image)
    
    options = {
      name: slide.text || "Slideshow Image",
      description: slide.text || "Slideshow Image",
      date_published: slide.created_at.strftime("%Y-%m-%d"),
      author: "Rozario Flowers"
    }
    
    generate_image_schema(image_url, options)
  end
  
  private
  
  # Convert relative image URL to full URL
  def full_image_url(image_path)
    return "" if image_path.nil? || image_path.empty?
    
    # If it's already a full URL, return as is
    return image_path if image_path.start_with?('http')
    
    # Otherwise, construct full URL
    subdomain_url = @subdomain.respond_to?(:url) ? @subdomain.url : 'rozarioflowers'
    base_url = "https://#{subdomain_url}.#{CURRENT_DOMAIN}"
    image_path.start_with?('/') ? "#{base_url}#{image_path}" : "#{base_url}/#{image_path}"
  end
end
