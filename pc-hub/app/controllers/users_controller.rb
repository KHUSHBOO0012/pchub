class UsersController < ApplicationController
	before_action :authenticate_user!
	before_action :set_user, only: [:show, :edit, :update, :destroy]
	load_and_authorize_resource :only => [:approve, :search, :edit, :new, :update, 
		:destroy]

	rescue_from CanCan::AccessDenied do |exception|
    	redirect_to main_app.root_url, :alert => exception.message
  	end

	# GET /users
	# GET /users.json
	def list
		if params[:approved] 
			@users = User.all
		else
			@users = User.where(approved: false)
		end
	end

	def search
		@users = User.search(params[:search]).order("created_at DESC")
	end

	def approve
		@user = User.find(params[:id])
		@user.update_attribute(:approved, true)
		redirect_to :back
	end

	# GET /users/1
	# GET /users/1.json
	def show
	end

	# GET /users/new
	def new
		@user = User.new
	end

	# GET /users/1/edit
	def edit
	end

	# POST /users
	# POST /users.json
	def create
	@user = User.new(user_params)

		respond_to do |format|
			if @user.save
				format.html { redirect_to @user, notice: 'User was successfully created.' }
				format.json { render :show, status: :created, location: @user }
			else
				format.html { render :new }
				format.json { render json: @user.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /users/1
	# PATCH/PUT /users/1.json
	def update
		respond_to do |format|
			if @user.update(user_params)
				format.html { redirect_to @user, notice: 'User was successfully updated.' }
				format.json { render :show, status: :ok, location: @user }
			else
				format.html { render :edit }
				format.json { render json: @user.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /users/1
	# DELETE /users/1.json
	def destroy
		@user.destroy
		respond_to do |format|
			format.html { redirect_to root_path, notice: 'User was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	private

	# Use callbacks to share common setup or constraints between actions.
	def set_user
		@user = User.find(params[:id])
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def user_params
		params.require(:user).permit(:name, :nickname, :email, :email_confirmation, 
		:password, :country, :state_or_province, :city, :profile_link, :additional_information, 
		:role, :approved)
	end
end