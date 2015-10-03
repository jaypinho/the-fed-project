class TermsController < ApplicationController

http_basic_authenticate_with :name => ENV['FED_USERNAME'], :password => ENV['FED_PASSWORD']

before_action :set_term, only: [:show, :edit, :update, :destroy]

def new
  @term = Term.new
end

def edit
end

def create
  @term = Term.new(term_params)

    if @term.save
      redirect_to projections_path, notice: 'New term was successfully created.'
    else
      render action: 'new'
    end
end


def update
  if @term.update(term_params)
    redirect_to member_path(@term.member)
  else
    render action: 'edit'
  end
end

def destroy
  @term.destroy
  redirect_to projections_path
end

private

def set_term
  @term = Term.find(params[:id])
end

def term_params
  params.require(:term).permit(:start_date, :end_date, :member_id)
end

end
