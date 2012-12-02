class Idea < ActiveRecord::Base
  attr_accessible :title

  has_many :components
end
