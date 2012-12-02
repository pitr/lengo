class IdeasController < ApplicationController
  def index
    @ideas = Idea.all
  end

  def show
    @idea = Idea.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @idea }
    end
  end

  def create
    @root_idea = Idea.create_from_json(params[:idea])

    render json: @root_idea, status: :created, location: @root_idea
  end

  def completed
    @root_idea = Idea.find_by_id(3)
  end
end
