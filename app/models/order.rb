# encoding: utf-8
class Order < ActiveRecord::Base
	belongs_to :useraccount, class_name: 'UserAccount'
	belongs_to :status, class_name: 'Status'
	has_many :smiles, foreign_key: 'order_id'
	#has_many :id, class_name: 'Order_product'
end