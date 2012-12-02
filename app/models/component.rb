class Component < ActiveRecord::Base
  attr_accessible :body, :idea, :parent, :priority

  belongs_to :idea
  belongs_to :parent, :class_name => 'Component'
  has_many :sub_components, :class_name => 'Component',:foreign_key => :parent_id
end
