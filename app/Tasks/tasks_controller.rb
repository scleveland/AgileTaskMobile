require 'rho/rhocontroller'
require 'helpers/browser_helper'

class TasksController < Rho::RhoController
  include BrowserHelper
  
  @@title = "Icebox"

  #GET /Tasks
  def index
    @@user = ""
    User.find(:all).map{|u| @@user = u}
    Rho::AsyncHttp.get(
                :url =>  "https://agiletask.me/tasks/icebox.json?api_key=#{@@user.api_key}",
                :callback => (url_for :action => :get_returned_tasks),
                :callback_param => "")
    render :action => :wait
  end
  
  def today
    @@title = "Today"
    @@user = ""
    User.find(:all).map{|u| @@user = u}
    Rho::AsyncHttp.get(
                :url =>  "https://agiletask.me/tasks/today.json?api_key=#{@@user.api_key}",
                :callback => (url_for :action => :get_returned_tasks),
                :callback_param => "")
    render :action => :wait
  end
  
  def icebox
    @@title = "Icebox"
    @@user = ""
    User.find(:all).map{|u| @@user = u}
    Rho::AsyncHttp.get(
                :url =>  "https://agiletask.me/tasks/icebox.json?api_key=#{@@user.api_key}",
                :callback => (url_for :action => :get_returned_tasks),
                :callback_param => "")
    render :action => :wait
  end
  
  def get_error
      @@error_params
  end
  
  # download_uncompleted_tasks
  # This connects to AgileTask and downloads all un-completed tasks
  #
  # @author: Sean Cleveland, Nanoqueis Technologies LLC
  # 
  def download_uncompleted_tasks
    # pull Icebox Tasks from AgileTask
    @@user = ""
    User.find(:all).map{|u| @@user = u}
    Rho::AsyncHttp.get(
                :url =>  "https://agiletask.me/tasks/icebox.json?api_key=#{@@user.api_key}",
                :callback => (url_for :action => :get_returned_sync_tasks),
                :callback_param => "")
    # pull Today TasksAgileTask
    Rho::AsyncHttp.get(
                :url =>  "https://agiletask.me/tasks/today.json?api_key=#{@@user.api_key}",
                :callback => (url_for :action => :get_returned_sync_tasks),
                :callback_param => "")
    render  :action => :wait
  end
  
  def get_created_task
    puts "httpget_callback: #{@params}"
    if @params['status'] != 'ok'
        http_error = @params['http_error'].to_i if @params['http_error']
            @@error_params = @params
            WebView.navigate ( url_for :action => :show_error )         
    else
        if @@title.nil?
          @@title == "Icebox"
        end
        if @@title == "Today"            
          WebView.navigate ( url_for  :action => :today)
        else
          WebView.navigate ( url_for  :action => :icebox)
        end
    end
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
  
  def get_returned_sync_tasks
    puts "httpget_callback: #{@params}"
    if @params['status'] != 'ok'
        http_error = @params['http_error'].to_i if @params['http_error']
            @@error_params = @params
            WebView.navigate ( url_for :action => :show_error )         
    else
        @@tasks= @params['body']
        @@tasks.each do |task|
          if task = Tasks.find(:all, :conditions=>{:id=>task["task"]["id"]})
            #if task.updated_at == 
          else
            Task.create(:id=>task["task"]["id"], 
                     :name=>task["task"]["name"],
                     :icebox=>task["task"]["icebox"],
                     :complete=>task["task"]["complete"], 
                     :updated_at=>task["task"]["updated_at"],
                     :created_at=>task["task"]["created_at"], 
                     :position=>task["task"]["position"],
                     :on_server=>true)
          end
        end
        WebView.navigate ( url_for :action => :show_sync_results )
    end
  end
  
  def show_result
   render :action => :show, :back => '/app'
  end
  
  def show_sync_results
    render :action => :show_sync, :back => '/app'
  end

  def get_sync_tasks
    Tasks.find(:all)
  end

  def show_error
   render :action => :error, :back => '/app'
  end

  def get_tasks
    @@tasks
  end
  
  def get_task_id
   @@task_id
  end
  def get_title
    @@title
  end
    
  def get_user
    @@user
  end
  
  def check_done
    @@task_id = @params['id']
    render :action => :done
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
    @user = ""
    User.find(:all).map{|u| @user = u}
    Rho::AsyncHttp.post(
                :url =>  "https://agiletask.me/tasks.json?task[name]='#{@params['task']}'&api_key=#{@user.api_key}",
                :callback => (url_for :action => :get_created_task),
                :callback_param => "")
    if !@@title.nil? && @@title == "Today"            
      redirect :action => :today 
    else
      redirect :action => :icebox
    end
  end

  # POST /Tasks/{1}/update
  def update
    @tasks = Tasks.find(@params['id'])
    @tasks.update_attributes(@params['tasks']) if @tasks
    redirect :action => :index
  end

  def to_icebox
    @user = ""
    User.find(:all).map{|u| @user = u}
    puts "https://agiletask.me/tasks/#{@params['icebox_task_id']}.json?task[icebox]=true&api_key=#{@user.api_key}"
    Rho::AsyncHttp.get(
                :http_command  => 'PUT',
                :headers => {"Content-Length" => 0},
                :url =>  "https://agiletask.me/tasks/#{@params['icebox_task_id']}.json?task[icebox]=true&api_key=#{@user.api_key}",
                :callback => (url_for :action => :get_created_task),
                :callback_param => "")
    render :wait
  end
  
  def to_today
    @user = ""
    User.find(:all).map{|u| @user = u}
    puts "https://agiletask.me/tasks/#{@params['today_task_id']}.json?task[icebox]=false&api_key=#{@user.api_key}"
    Rho::AsyncHttp.get(
                :http_command  => 'PUT',
                :headers => {"Content-Length" => 0},
                :url =>  "https://agiletask.me/tasks/#{@params['today_task_id']}.json?task[icebox]=false&api_key=#{@user.api_key}",
                :callback => (url_for :action => :get_created_task),
                :callback_param => "")
    render :wait
  end
  
  def completed
    @user = ""
    User.find(:all).map{|u| @user = u}
    puts "Params:" 
    puts @params
    puts "https://agiletask.me/tasks/#{@params['comp_task_id']}.json?task[complete]=true&api_key=#{@user.api_key}"
    Rho::AsyncHttp.get(
                :http_command  => 'PUT',
                :headers => {"Content-Length" => 0},
                :url =>  "https://agiletask.me/tasks/#{@params['comp_task_id']}.json?task[complete]=true&api_key=#{@user.api_key}",
                :callback => (url_for :action => :get_created_task),
                :callback_param => "")
    render :wait
  end

  # POST /Tasks/{1}/delete
  def delete
    @tasks = Tasks.find(@params['id'])
    @tasks.destroy if @tasks
    redirect :action => :index
  end
end
