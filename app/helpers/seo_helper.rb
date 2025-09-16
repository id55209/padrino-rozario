# encoding: utf-8
Rozario::App.helpers do
  # def simple_helper_method
  #  ...
  # end
  def wrap_seo_params(params_hash)
    result_hash = params_hash.clone
    known_inserts = {}
    #insert params by id
    result_hash.each_value do |v|
      next if v.nil? || v.class == UploaderOg || v.class == UploaderTwitter
      v.scan(/%pattern\d+%/i).each do |entry|

        id = entry.match(/\d+/)[0].to_s.to_i
        # raise id.inspect
        result = Pattern.where(id: id)
        data_to_replace = ''
        if result.length > 0
          data_to_replace = result.first.content
        end
        v.sub!(entry, data_to_replace)
      end
    end
    # raise result_hash.inspect
    #insert subdomains values
    # @subdomain = Subdomain.all.first
    if @subdomain
      result_hash.each_value do |v|
        next if v.nil? || v.class == UploaderOg || v.class == UploaderTwitter
        v.gsub!(/%city%/, "#{@subdomain.city}")
        v.gsub!(/%in_city%/, "в #{@subdomain.city}")
        v.gsub!(/%suffix%/, "#{@subdomain.suffix}")
        v.gsub!(/%morph%/, "#{@subdomain.get_morph('loc2')}")
      	v.gsub!(/%morph_datel%/, "#{@subdomain.morph_datel}")
      	v.gsub!(/%morph_predl%/, "#{@subdomain.morph_predl}")
      	v.gsub!(/%morph_rodit%/, "#{@subdomain.morph_rodit}")
      end
    end

    if @products
      result_hash.each_value do |v|
        next if v.nil? || v.class == UploaderOg || v.class == UploaderTwitter || @products.kind_of?(Array)
        v.gsub!(/%h%/, "#{@products.header}")
      end
    end
    
    if @product || @page || @product
      result_hash.each_value do |v|
        next if v.nil? || v.class == UploaderOg || v.class == UploaderTwitter

      end
    end
    #insert categories and tags if product
    #insert bu slug
    # raise @subdomain.
    if @product
      # raise @product.categories.inspect
      categories = @product.categories.map(&:title).map(&:strip).uniq.join(', ')
      tags = @product.tags.map(&:title).map(&:strip).uniq.join(', ')
      result_hash.each_value do |v|
        next if v.nil? || v.class == UploaderOg || v.class == UploaderTwitter || @product.kind_of?(Array)
        v.gsub!(/%categories%/, "#{categories}")
        v.gsub!(/%tags%/, "#{tags}")
      end
    end

    if @article || @category || @news || @smile || @product || @products
      result_hash.each_value do |v|
        next if v.nil? || v.class == UploaderOg || v.class == UploaderTwitter|| @news.kind_of?(Array)
        v.gsub!(/%header%/, "#{@article.title}") if @article
        v.gsub!(/%header%/, "#{@category.title}") if @category
        v.gsub!(/%header%/, "#{@news.title}") if @news
        v.gsub!(/%header%/, "#{@smile.title}") if @smile
        v.gsub!(/%header%/, "#{@products.header}") if @products
        v.gsub!(/%header%/, "#{@product.header}") if @product
        v.gsub!(/%header%/, "#{@page.header}") if @page
      end
    end

    # raise result_hash.inspect
    result_hash.each_value do |v|
      next if v.nil? || v.class == UploaderOg || v.class == UploaderTwitter
      v.scan(/%\w+%/).uniq.each do |pattern|
        slug = pattern.gsub('%', '')
        string_to_replace = ''
        patterns = Pattern.where(slug: slug)
        if patterns.length > 0
          string_to_replace = patterns.first.content
        end
        v.gsub!(pattern, "#{string_to_replace}")
      end
    end
    result_hash
  end

  def set_seo_tags_for_page(page)
    wrap_seo_params(
      title: page.title,
      description: page.description,
      # keywords: page.keywords,
      h1: page.h1,
      og_type: page.og_type,
      og_title: page.og_title,
      og_description: page.og_description,
      og_site_name: page.og_site_name,
      twitter_title: page.twitter_title,
      twitter_description: page.twitter_description,
      twitter_site: page.twitter_site,
      twitter_image_alt: page.twitter_image_alt,
      twitter_image: page.twitter_image,
      og_image: page.og_image
    )
  end
end
def get_seo_data(page, id = nil, index = false)

  x = id.present? ? Seo.find(id) : nil
  seo = set_seo_tags_for_page(x) if x
  def_seo = set_seo_tags_for_page(SeoGeneral.find_by_name(page)) if SeoGeneral.find_by_name(page).present?
  all_seo = set_seo_tags_for_page(SeoGeneral.find_by_name('default')) if SeoGeneral.find_by_name('default').present?

  @seo = {index: x ? x.index : index }

  seo     &&  seo[:title].present?     ? @seo[:title] = seo[:title]      :
  def_seo &&  def_seo[:title].present? ? @seo[:title] = def_seo[:title]  :
  all_seo &&  all_seo[:title].present? ? @seo[:title] = all_seo[:title]  : ''

  seo     &&  seo[:description].present?     ? @seo[:description] = seo[:description]      :
  def_seo &&  def_seo[:description].present? ? @seo[:description] = def_seo[:description]  :
  all_seo &&  all_seo[:description].present? ? @seo[:description] = all_seo[:description]  : ''

  # seo     &&  seo[:keywords].present?     ? @seo[:keywords] = seo[:keywords]      :
  # def_seo &&  def_seo[:keywords].present? ? @seo[:keywords] = def_seo[:keywords]  :
  # all_seo &&  all_seo[:keywords].present? ? @seo[:keywords] = all_seo[:keywords]  : ''

  seo     &&  seo[:og_type].present?     ? @seo[:og_type] = seo[:og_type]      :
  def_seo &&  def_seo[:og_type].present? ? @seo[:og_type] = def_seo[:og_type]  :
  all_seo &&  all_seo[:og_type].present? ? @seo[:og_type] = all_seo[:og_type]  : 'website'

  seo     &&  seo[:og_title].present?     ? @seo[:og_title] = seo[:og_title]      :
  def_seo &&  def_seo[:og_title].present? ? @seo[:og_title] = def_seo[:og_title]  :
  all_seo &&  all_seo[:og_title].present? ? @seo[:og_title] = all_seo[:og_title]  : ''

  seo     &&  seo[:og_description].present?     ? @seo[:og_description] = seo[:og_description]      :
  def_seo &&  def_seo[:og_description].present? ? @seo[:og_description] = def_seo[:og_description]  :
  all_seo &&  all_seo[:og_description].present? ? @seo[:og_description] = all_seo[:og_description]  : ''

  seo     &&  seo[:og_image].url     ? @seo[:og_image] = options.host + seo[:og_image].url      :
  def_seo &&  def_seo[:og_image].url ? @seo[:og_image] = options.host + def_seo[:og_image].url  :
  all_seo &&  all_seo[:og_image].url ? @seo[:og_image] = options.host + all_seo[:og_image].url  : ''

  seo     &&  seo[:twitter_title].present?     ? @seo[:twitter_title] = seo[:twitter_title]      :
  def_seo &&  def_seo[:twitter_title].present? ? @seo[:twitter_title] = def_seo[:twitter_title]  :
  all_seo &&  all_seo[:twitter_title].present? ? @seo[:twitter_title] = all_seo[:twitter_title]  : ''

  seo     &&  seo[:twitter_description].present?     ? @seo[:twitter_description] = seo[:twitter_description]      :
  def_seo &&  def_seo[:twitter_description].present? ? @seo[:twitter_description] = def_seo[:twitter_description]  :
  all_seo &&  all_seo[:twitter_description].present? ? @seo[:twitter_description] = all_seo[:twitter_description]  : ''

  seo     &&  seo[:twitter_image].url     ? @seo[:twitter_image] = options.host + seo[:twitter_image].url       :
  def_seo &&  def_seo[:twitter_image].url ? @seo[:twitter_image] = options.host + def_seo[:twitter_image].url   :
  all_seo &&  all_seo[:twitter_image].url ? @seo[:twitter_image] = options.host + all_seo[:twitter_image].url   : ''

  if index || x && x.index
    seo     &&  seo[:h1].present?     ? @seo[:h1] = seo[:h1]      :
    def_seo &&  def_seo[:h1].present? ? @seo[:h1] = def_seo[:h1]  :
    all_seo &&  all_seo[:h1].present? ? @seo[:h1] = all_seo[:h1]  : ''
  end
end