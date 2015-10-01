class StatementsController < ApplicationController

  http_basic_authenticate_with :name => ENV['FED_USERNAME'], :password => ENV['FED_PASSWORD'], except: [:index, :show]

  before_action :set_statement, only: [:show, :edit, :update, :destroy]

  def index
    @statements = Statement.all
  end

  def show
  end

  def new
    @statement = Statement.new
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
    params.require(:statement).permit(:url, :summary, :lean, :pub_date, :statement_date, :member_id)
  end

end
