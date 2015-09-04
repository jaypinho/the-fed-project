class ProjectionsController < ApplicationController

  http_basic_authenticate_with :name => ENV['FED_USERNAME'], :password => ENV['FED_PASSWORD'], except: [:index]

  before_action :set_projection, only: [:show, :edit, :update, :destroy]

  def index
    @projections = Projection.select('projections.*, key_rates.actual_rate').where("fulfillment_date <= ?", Date.today).joins('LEFT JOIN key_rates on key_rates.rate_date = projections.fulfillment_date').order(present_date: :asc, fulfillment_date: :asc, projected_rate: :asc)
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
              days_in_advance: (x.present_date - x.fulfillment_date).to_i,
              projection_discrepancy: (x.projected_rate - x.actual_rate).abs.to_f,
              projected_date: x.fulfillment_date.strftime('%Y-%m-%d'),
              projected_rate: x.projected_rate.to_f,
              date_of_projection: x.present_date.strftime('%B %e, %Y')
            }

          # We've moved on to a different set of projections (new date of projection, fulfillment, or both)
          else
            @chart_data += preliminary_chart_data[(0 + trim_num)..(-1 - trim_num)]

            # Reset variables for next set of projections
            current_date = x.present_date
            end_date = x.fulfillment_date
            preliminary_chart_data = [{
              days_in_advance: (x.present_date - x.fulfillment_date).to_i,
              projection_discrepancy: (x.projected_rate - x.actual_rate).abs.to_f,
              projected_date: x.fulfillment_date.strftime('%Y-%m-%d'),
              projected_rate: x.projected_rate.to_f,
              date_of_projection: x.present_date.strftime('%B %e, %Y')
            }]

          end

        end

        @chart_data += preliminary_chart_data[(0 + trim_num)..(-1 - trim_num)]

      else

        @projections.each do |x|
          @chart_data << {
            days_in_advance: (x.present_date - x.fulfillment_date).to_i,
            projection_discrepancy: (x.projected_rate - x.actual_rate).abs.to_f,
            projected_date: x.fulfillment_date.strftime('%Y-%m-%d'),
            projected_rate: x.projected_rate.to_f,
            date_of_projection: x.present_date.strftime('%B %e, %Y')
          }
        end

      end

    @rate_info = []
    @date_info = []
    KeyRate.all.order(rate_date: :asc).each{|x| @date_info << x.rate_date.strftime('%Y-%m-%d'); @rate_info << x.actual_rate.to_f}

    @regression_data = {
      sum_of_x: 0,
      sum_of_y: 0,
      sum_of_x_2: 0,
      sum_of_x_times_y: 0,
      n_total: 0,
      lowest_x: 0
    }

    @chart_data.each do |x|
      @regression_data[:sum_of_x] += x[:days_in_advance].abs
      @regression_data[:sum_of_y] += x[:projection_discrepancy]
      @regression_data[:sum_of_x_2] += x[:days_in_advance].abs ** 2
      @regression_data[:sum_of_x_times_y] += x[:days_in_advance].abs * x[:projection_discrepancy]
      @regression_data[:n_total] += 1
      @regression_data[:lowest_x] = x[:days_in_advance] if x[:days_in_advance] < @regression_data[:lowest_x]
    end

    @regression_slope = (
                          @regression_data[:sum_of_x_times_y] -
                          ((@regression_data[:sum_of_x] * @regression_data[:sum_of_y]) /
                          @regression_data[:n_total])
                          ) /
                        (
                          @regression_data[:sum_of_x_2] -
                          ((@regression_data[:sum_of_x] ** 2) /
                          @regression_data[:n_total])
                        )

    @regression_slope = -@regression_slope
    @y_intercept = @chart_data[0][:projection_discrepancy] - (@regression_slope * @chart_data[0][:days_in_advance].abs)

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
