class ProjectionsController < ApplicationController

  before_action :set_projection, only: [:show, :edit, :update, :destroy]

  def index
    @projections = Projection.all
  end

  def show
  end

  def new
    @projection = Projection.new
  end

  def edit
  end

  def create
    @projection = Projection.new(projection_params)
    if @projection.save
      redirect_to @projection
    else
      render action: 'new'
    end
  end

  def update
    if @projection.update(projection_params)
      redirect_to @projection
    else
      render action: 'edit'
    end
  end

  def destroy
    @projection.destroy
    redirect_to projections_path
  end

  private

  def set_projection
    @projection = Projection.find(params[:id])
  end

  def projection_params
    params.require(:projection).permit(:present_date, :projected_rate, :fulfillment_date)
  end

end
