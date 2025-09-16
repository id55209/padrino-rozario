# encoding: utf-8
Rozario::App.controllers :album do

  get :index do
    puts "Рендеринг альбома get :index do album.rb"
    #lamer's way
    #all_albums = Album.all()
    #@albums = []
    #all_albums.each do |album|
    #  puts '-------------------------'
    #  if !album.photos.empty?
    #    last_photo = Photo.where(:album_id => album.id).last
    #    h = [:album_id => album.id, :album_title => album.title , :last_photo => last_photo.image]
    #    @albums.push h
    #  end
    #  puts '-------------------------'
    #end
    #p @albums
    @albums = Album.all()
    render 'album/index'
  end

  get :index, :with => :id do
    puts "Запрос из базы данных Album id get :index, :with => :id do"
    @album = Album.find_by_id(params[:id])
    if @album.blank?
    	error 404
    end
    render 'album/show'
  end

end
