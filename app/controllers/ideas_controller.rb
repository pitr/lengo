class IdeasController < ApplicationController
  def index
  end

  def create
    @root_idea = Idea.create_from_json(params[:idea])

    render json: @root_idea, status: :created, location: @root_idea
  end
end
