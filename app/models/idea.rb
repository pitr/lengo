class Idea < ActiveRecord::Base
  attr_accessible :title, :idea, :parent, :priority

  belongs_to :parent, :class_name => 'Idea'
  has_many :sub_ideas, :class_name => 'Idea', :foreign_key => :parent_id

  has_many :components

  def self.create_from_json(json)
    idea = Idea.create title: json['title']
    idea.create_from_json(json)
    idea
  end

  def create_from_json(json)
    json['sub_ideas'].try(:each) do |_, sub_json|
      sub_idea = self.sub_ideas.build title: sub_json['title']
      sub_idea.create_from_json(sub_json)
      sub_idea.save!
    end
    if json['duration'].present?
      self.duration = ChronicDuration.parse(json['duration'])
    end
    self.save!
  end
end
