class ProjectionsController < ApplicationController

  http_basic_authenticate_with :name => ENV['FED_USERNAME'], :password => ENV['FED_PASSWORD'], except: [:index, :d3_get_chart_source_data]

  before_action :set_projection, only: [:show, :edit, :update, :destroy]

  def index
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

  def d3_get_chart_source_data

    # Below is the SQL query I want to use for the projection errors chart:

=begin
select DaysUntil, ProjectionError, sum(ProjectionsCount) from (

select present_date, fulfillment_date, projected_rate, actual_rate, (fulfillment_date - present_date) As DaysUntil, Abs(actual_rate-projected_rate) As ProjectionError, count(*) As ProjectionsCount
from projections
join key_rates on key_rates.rate_date = projections.fulfillment_date
where fulfillment_date <> '2025-12-31'
group by present_date, fulfillment_date, projected_rate, actual_rate
order by present_date asc, fulfillment_date asc, count(*) desc 

) AggProjections

group by DaysUntil, ProjectionError
order by DaysUntil asc, ProjectionError asc
=end



    trim = params.has_key?(:trim) ? params[:trim].to_i : 0

    sql = "WITH revised_projections As (
      select
        id,
        present_date,
        fulfillment_date,
        projected_rate,
        min(projected_rate) over (partition by present_date, fulfillment_date) As min_projected_rate,
        max(projected_rate) over (partition by present_date, fulfillment_date) As max_projected_rate,
        row_number() over (partition by present_date, fulfillment_date order by projected_rate asc) As lowest_rate_row,
        count(*) over (partition by present_date, fulfillment_date) as projection_count
      from projections
    )
    select *
    from revised_projections
    where lowest_rate_row > #{trim} AND lowest_rate_row <= (projection_count - #{trim})
    order by present_date asc, fulfillment_date, lowest_rate_row asc"

    
    base_query = ActiveRecord::Base.connection.execute(sql)
    eligible_ids = base_query.to_a.map{ |a| a['id'] }

    from_sql = Projection.select('present_date, fulfillment_date, projected_rate, key_rates.actual_rate, (fulfillment_date - present_date) As days_until, Abs(key_rates.actual_rate - projected_rate) As projection_error, count(*) As projection_count').joins('join key_rates on key_rates.rate_date = projections.fulfillment_date').includes(:key_rates).where('projections.fulfillment_date <> ? AND projections.id in (?)', LONG_RUN_PLACEHOLDER_DATE, eligible_ids).group('present_date, fulfillment_date, projected_rate, key_rates.actual_rate').order(present_date: :asc, fulfillment_date: :asc).to_sql

    json_response = {
      "actual_rates": KeyRate.all.select(:rate_date, :actual_rate).order(rate_date: :asc),

      "projected_rates": Projection.select('fulfillment_date, min(projected_rate), max(projected_rate), avg(projected_rate), PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY projected_rate) As median, count(*)').where('fulfillment_date <> ? AND id in (?)', LONG_RUN_PLACEHOLDER_DATE, eligible_ids).group(:fulfillment_date).order(fulfillment_date: :asc),

      "projected_long_term_rates": Projection.select('present_date, min(projected_rate), max(projected_rate), avg(projected_rate), PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY projected_rate) As median, count(*)').where('fulfillment_date = ? AND id in (?)', LONG_RUN_PLACEHOLDER_DATE, eligible_ids).group(:present_date).order(present_date: :asc),

      "projected_rates_detail": Projection.select('days_until, projection_error, sum(projection_count) As projection_total').from("(#{from_sql}) as aggregated_projected_and_actual_rates").group(:days_until, :projection_error).order('projection_total desc, days_until asc, projection_error asc'),

      "projections_by_meeting": Projection.select('present_date, fulfillment_date, min(projected_rate), max(projected_rate), avg(projected_rate), PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY projected_rate) As median, (fulfillment_date - present_date) As days_until, count(*)').where('id in (?)', eligible_ids).group(:present_date, :fulfillment_date).order(present_date: :asc, fulfillment_date: :asc),

      "total_filtered_projections": eligible_ids.count
    }

    respond_to do |format|
      format.json { render json: json_response }
    end

  end

  private

  def set_projection
    @projection = Projection.find(params[:id])
  end

  def projection_params
    params.require(:projection).permit(:present_date, :projected_rate, :fulfillment_date)
  end

end
