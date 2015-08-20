class ProjectionsController < ApplicationController

  before_action :set_projection, only: [:show, :edit, :update, :destroy]

  def index
    @projections = Projection.where(:fulfillment_date => '2015-12-31')
    @chart_data = []
    @projections.each do |x|
      @chart_data << {
        x: (x.fulfillment_date - x.present_date).to_i,
        y: (x.projected_rate - 0.125).to_f
      }
    end
  end

  def show
  end

  def new
    @projection = Projection.new
  end

  def edit
  end

  def create
    (1..(params[:voters].to_i)).each do |x|
      @projection = Projection.new(projection_params)
      @projection.save
    end
    redirect_to new_projection_path
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
