class ProjectionsController < ApplicationController

  before_action :set_projection, only: [:show, :edit, :update, :destroy]

  def index
    @projections = Projection.where(:fulfillment_date => '2015-12-31').order(present_date: :asc, fulfillment_date: :asc, projected_rate: :asc)
    @chart_data = []

      if params.has_key?(:trim) && params[:trim].to_i > 0

        current_date = nil
        end_date = nil
        preliminary_chart_data = []
        trim_num = params[:trim].to_i
        trim_num = 7 if trim_num > 7

        @projections.each do |x|

          # Check if we're in the middle of a set of projections (projected on a certain date for a certain date)
          if current_date.nil? || (current_date == x.present_date && end_date == x.fulfillment_date)
            current_date = x.present_date if current_date.nil?
            end_date = x.fulfillment_date if end_date.nil?

            preliminary_chart_data << {
              x: (x.fulfillment_date - x.present_date).to_i,
              y: (x.projected_rate - 0.125).to_f
            }

          # We've moved on to a different set of projections (new date of projection, fulfillment, or both)
          else
            @chart_data += preliminary_chart_data[(0 + trim_num)..(-1 - trim_num)]

            # Reset variables for next set of projections
            current_date = x.present_date
            end_date = x.fulfillment_date
            preliminary_chart_data = [{
              x: (x.fulfillment_date - x.present_date).to_i,
              y: (x.projected_rate - 0.125).to_f
            }]

          end

        end

        @chart_data += preliminary_chart_data[(0 + trim_num)..(-1 - trim_num)]

      else

        @projections.each do |x|
          @chart_data << {
            x: (x.fulfillment_date - x.present_date).to_i,
            y: (x.projected_rate - 0.125).to_f
          }
        end

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
