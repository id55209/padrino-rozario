# encoding: utf-8
class Album < ActiveRecord::Base
	has_many :photos, :class_name => 'Photo'
  	accepts_nested_attributes_for :photos, :allow_destroy => true
end
