# encoding: utf-8
class Photo < ActiveRecord::Base
	belongs_to :album
	mount_uploader :image, UploaderPhoto
end
