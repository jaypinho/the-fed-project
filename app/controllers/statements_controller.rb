class StatementsController < ApplicationController

  http_basic_authenticate_with :name => ENV['FED_USERNAME'], :password => ENV['FED_PASSWORD'], except: [:index, :show]

  before_action :set_statement, only: [:show, :edit, :update, :destroy]

  def index
    @statements = Statement.exclude_non_voting(params[:filter]).exclude_non_voting_as_of_now(params[:filter_as_of_now]).exclude_similar_to_prior(params[:filter_when_prior]).order(statement_date: :desc)
    respond_to do |format|
      format.html
      format.json { render json: @statements }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @statement }
    end
  end

  def new

    respond_to do |format|
      format.html {
        @statements = Statement.all.order(statement_date: :desc)
        @statement = Statement.new
      }
      format.js {
        @statements = Statement.where(:member_id => params[:member_id].to_i).order(statement_date: :desc)
      }
    end

  end

  def edit
  end

  def create
    @statement = Statement.new(statement_params)

      if @statement.save
        redirect_to @statement, notice: 'New statement was successfully created.'
      else
        render action: 'new'
      end
  end


  def update
    if @statement.update(statement_params)
      redirect_to @statement
    else
      render action: 'edit'
    end
  end

  def destroy
    @statement.destroy
    redirect_to projections_path
  end

  private

  def set_statement
    @statement = Statement.find(params[:id])
  end

  def statement_params
    params.require(:statement).permit(:url, :summary, :lean, :pub_date, :statement_date, :similar_to_prior, :member_id)
  end

end
