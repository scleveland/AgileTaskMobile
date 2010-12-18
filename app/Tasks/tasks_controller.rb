require 'rho/rhocontroller'
require 'helpers/browser_helper'

class TasksController < Rho::RhoController
  include BrowserHelper

  #GET /Tasks
  def index
    Rho::AsyncHttp.get(
                :url =>  "https://agiletask.me/tasks/icebox.json?api_key=",
                :callback => (url_for :action => :get_returned_tasks),
                :callback_param => "")
    render :action => :wait
  end
  
  def today
    Rho::AsyncHttp.get(
                :url =>  "https://agiletask.me/tasks/today.json?api_key=",
                :callback => (url_for :action => :get_returned_tasks),
                :callback_param => "")
    render :action => :wait
  end
  
  def icebox
    Rho::AsyncHttp.get(
                :url =>  "https://agiletask.me/tasks/icebox.json?api_key=",
                :callback => (url_for :action => :get_returned_tasks),
                :callback_param => "")
    render :action => :wait
  end
  
  def get_error
      @@error_params
  end
  
  def get_returned_tasks
    puts "httpget_callback: #{@params}"
    if @params['status'] != 'ok'
        http_error = @params['http_error'].to_i if @params['http_error']
            @@error_params = @params
            WebView.navigate ( url_for :action => :show_error )         
    else
        @@tasks= @params['body']
        WebView.navigate ( url_for :action => :show_result )
    end
  end
  
  def show_result
   render :action => :show, :back => '/app'
  end

  def show_error
   render :action => :error, :back => '/app'
  end

  def get_tasks
    @@tasks
  end

  def cancel_httpcall
    Rho::AsyncHttp.cancel( url_for( :action => :httpget_callback) )

    @@get_result  = 'Request was cancelled.'
    render :action => :index, :back => '/app'
  end

  # GET /Tasks/{1}
  def show
    @tasks = Tasks.find(@params['id'])
    if @tasks
      render :action => :show
    else
      redirect :action => :index
    end
  end

  # GET /Tasks/new
  def new
    @tasks = Tasks.new
    render :action => :new
  end

  # GET /Tasks/{1}/edit
  def edit
    @tasks = Tasks.find(@params['id'])
    if @tasks
      render :action => :edit
    else
      redirect :action => :index
    end
  end

  # POST /Tasks/create
  def create
    @tasks = Tasks.create(@params['tasks'])
    redirect :action => :index
  end

  # POST /Tasks/{1}/update
  def update
    @tasks = Tasks.find(@params['id'])
    @tasks.update_attributes(@params['tasks']) if @tasks
    redirect :action => :index
  end

  # POST /Tasks/{1}/delete
  def delete
    @tasks = Tasks.find(@params['id'])
    @tasks.destroy if @tasks
    redirect :action => :index
  end
end