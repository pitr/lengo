class Idea < ActiveRecord::Base
  attr_accessible :title
  attr_accessible :title, :idea, :parent, :priority

  belongs_to :parent, :class_name => 'Idea'
  has_many :sub_components, :class_name => 'Idea', :foreign_key => :parent_id

  has_many :components
end
