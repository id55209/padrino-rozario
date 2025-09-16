require 'minitest/autorun'
require 'json'
require 'ostruct'

# Define CURRENT_DOMAIN constant for tests
CURRENT_DOMAIN = 'rozarioflowers.ru' unless defined?(CURRENT_DOMAIN)

# Test helper class that will receive helper methods
class TestHelper
  def initialize(subdomain = nil)
    @subdomain = subdomain
  end
  
  # Mock content_tag method
  def content_tag(tag, content, attributes = {})
    attr_string = attributes.map { |k, v| "#{k}=\"#{v}\"" }.join(" ")
    "<#{tag} #{attr_string}>#{content}</#{tag}>"
  end
end

# Mock Rozario::App for testing
module Rozario
  class App
    def self.helpers(&block)
      TestHelper.class_eval(&block) if block_given?
    end
  end
end

require_relative '../app/helpers/schema_helper'

# Mock classes to simulate the application models
class MockProduct
  attr_accessor :header, :alt, :created_at, :id
  
  def initialize(header: "Test Product", alt: "Test Alt", created_at: nil)
    @header = header
    @alt = alt
    @created_at = created_at || Time.now
    @id = 1
  end
  
  def thumb_image(mobile = false)
    "/images/test_product.jpg"
  end
end

class MockPhoto
  attr_accessor :title, :image, :created_at
  
  def initialize(title: "Test Photo", image: "/images/test_photo.jpg")
    @title = title
    @image = image
    @created_at = Time.now
  end
end

class MockSlide
  attr_accessor :text, :image, :created_at
  
  def initialize(text: "Test Slide", image: "/images/test_slide.jpg")
    @text = text
    @image = image
    @created_at = Time.now
  end
end

# Mock subdomain for testing
class MockSubdomain
  attr_accessor :url
  
  def initialize(url = "test")
    @url = url
  end
end

# Add html_safe method to String for compatibility
class String
  def html_safe
    self
  end
end

class SchemaHelperTest < Minitest::Test
  def setup
    @helper = TestHelper.new
    @subdomain = MockSubdomain.new("testcity")
    @helper_with_subdomain = TestHelper.new(@subdomain)
  end
  
  def test_generate_basic_image_schema
    result = @helper.generate_image_schema("https://example.com/image.jpg")
    assert_includes result, '"@context": "http://schema.org"'
    assert_includes result, '"@type": "ImageObject"'
    assert_includes result, '"contentUrl": "https://example.com/image.jpg"'
    assert_includes result, '"author": "Rozario Flowers"'
  end
  
  def test_generate_image_schema_with_options
    options = {
      name: "Test Image",
      description: "Test Description",
      width: "100",
      height: "200"
    }
    result = @helper.generate_image_schema("https://example.com/image.jpg", options)
    assert_includes result, '"name": "Test Image"'
    assert_includes result, '"description": "Test Description"'
    assert_includes result, '"width": "100"'
    assert_includes result, '"height": "200"'
  end
  
  def test_product_image_schema_mobile
    product = MockProduct.new
    result = @helper_with_subdomain.product_image_schema(product, true)
    assert_includes result, '"@type": "ImageObject"'
    assert_includes result, '"name": "Test Product"'
    assert_includes result, '"description": "Test Alt"'
    assert_includes result, '"author": "Rozario Flowers"'
    assert_includes result, '"width": "650"'
    assert_includes result, '"height": "650"'
  end
  
  def test_product_image_schema_desktop
    product = MockProduct.new
    result = @helper_with_subdomain.product_image_schema(product, false)
    assert_includes result, '"width": "1315"'
    assert_includes result, '"height": "650"'
  end
  
  def test_photo_image_schema
    photo = MockPhoto.new
    result = @helper_with_subdomain.photo_image_schema(photo)
    assert_includes result, '"@type": "ImageObject"'
    assert_includes result, '"name": "Test Photo"'
    assert_includes result, '"description": "Test Photo"'
    assert_includes result, '"author": "Rozario Flowers"'
  end
  
  def test_slide_image_schema
    slide = MockSlide.new
    result = @helper_with_subdomain.slide_image_schema(slide)
    assert_includes result, '"@type": "ImageObject"'
    assert_includes result, '"name": "Test Slide"'
    assert_includes result, '"description": "Test Slide"'
    assert_includes result, '"author": "Rozario Flowers"'
  end
  
  def test_full_image_url_with_subdomain
    result = @helper_with_subdomain.send(:full_image_url, "/images/test.jpg")
    assert_equal "https://testcity.rozarioflowers.ru/images/test.jpg", result
  end
  
  def test_full_image_url_already_full
    result = @helper_with_subdomain.send(:full_image_url, "https://example.com/test.jpg")
    assert_equal "https://example.com/test.jpg", result
  end
  
  def test_generated_json_is_valid
    result = @helper.generate_image_schema("https://example.com/image.jpg")
    # Extract JSON from the script tag
    json_match = result.match(/<script[^>]*>(.+)<\/script>/m)
    refute_nil json_match
    
    json_str = json_match[1]
    parsed = JSON.parse(json_str)
    
    assert_equal "http://schema.org", parsed["@context"]
    assert_equal "ImageObject", parsed["@type"]
    assert_equal "https://example.com/image.jpg", parsed["contentUrl"]
    assert_equal "Rozario Flowers", parsed["author"]
  end
  
  def test_handles_missing_methods_gracefully
    broken_product = Object.new
    result = @helper_with_subdomain.product_image_schema(broken_product, true)
    assert_equal "", result
  end
  
  def test_handles_nil_values_gracefully
    result = @helper_with_subdomain.product_image_schema(nil, true)
    assert_equal "", result
  end
  
  def test_smile_image_schema
    smile = OpenStruct.new(images_identifier: "test.jpg", title: "Test Smile", created_at: Time.now)
    result = @helper_with_subdomain.smile_image_schema(smile, "Test Alt Text")
    assert_includes result, '"@type": "ImageObject"'
    assert_includes result, '"name": "Test Alt Text"'
  end
  
  def test_category_image_schema
    category = OpenStruct.new(image: "/test.jpg", title: "Test Category", created_at: Time.now)
    result = @helper_with_subdomain.category_image_schema(category)
    assert_includes result, '"@type": "ImageObject"'
    assert_includes result, '"name": "Test Category"'
  end
  
  def test_product_modal_image_schema
    product = MockProduct.new
    result = @helper_with_subdomain.product_modal_image_schema(product, "image")
    assert_includes result, '"@type": "ImageObject"'
    assert_includes result, '"contentUrl": "{{ image }}"'
  end
end
