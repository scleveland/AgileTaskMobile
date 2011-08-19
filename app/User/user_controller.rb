require 'rho/rhocontroller'
require 'helpers/browser_helper'

class UserController < Rho::RhoController
  include BrowserHelper

  #GET /User
  def index
    @users = User.find(:all)
    render
  end

  # GET /User/{1}
  def show
    @user = User.find(@params['id'])
    if @user
      render :action => :show
    else
      redirect :action => :index
    end
  end

  # GET /User/new
  def new
    @user = User.new
    render :action => :new
  end

  # GET /User/{1}/edit
  def edit
    @user = User.find(@params['id'])
    if @user
      render :action => :edit
    else
      redirect :action => :index
    end
  end

  # POST /User/create
  def create
    @user = User.create(@params['user'])
    redirect :action => :index
  end

  # POST /User/{1}/update
  def update
    @user = User.find(@params['id'])
    @user.update_attributes(@params['user']) if @user
    redirect :action => :index
  end

  # POST /User/{1}/delete
  def delete
    @user = User.find(@params['id'])
    @user.destroy if @user
    redirect :action => :index
  end
end
