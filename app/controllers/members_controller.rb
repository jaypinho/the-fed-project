class MembersController < ApplicationController

before_action :set_member, only: [:show, :edit, :update, :destroy]

def index
  @members = Member.all
end

def show
end

def new
  @member = Member.new
end

def edit
end

def create
  @member = Member.new(member_params)

    if @member.save
      redirect_to @member, notice: 'New member was successfully created.'
    else
      render action: 'new'
    end
end


def update
  if @member.update(member_params)
    redirect_to @member
  else
    render action: 'edit'
  end
end

def destroy
  @member.destroy
  redirect_to projections_path
end

private

def set_member
  @member = Member.find(params[:id])
end

def member_params
  params.require(:member).permit(:name, :member_type, :dob, :bio)
end

end
