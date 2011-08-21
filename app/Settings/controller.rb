require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'helpers/browser_helper'

class SettingsController < Rho::RhoController
  include BrowserHelper
  
  @@msg = ""
  def index
    @msg = @params['msg']
    render
  end

  def login
    @msg = @params['msg']
    if @msg.nil?
      @msg = @@msg
    end
    render :action => :login, :back => '/app'
  end

  def login_callback
    puts "httpget_callback: #{@params['body']}"
    if @params['body'].has_key?("api_key")
      user = User.create(:login => @params['body']["login"], :api_key=>@params['body']["api_key"]) #add api_key
      WebView.navigate('/app')
    else
      @@msg = "Incorrect User Credentials"
      WebView.navigate(url_for :action => :login)
    end  
  end

  def do_login
    # if @params['login'] and @params['password']
    #   begin
        Rho::AsyncHttp.get(
                    :url =>  "https://agiletask.me/users/api_key.json?login=#{@params['login']}&password=#{@params['password']}",
                    :callback => (url_for :action => :login_callback ),
                    :callback_param => "")
        # Rho::AsyncHttp.get(
        #             :url => "https://agiletask.me/users/api_key.json?login=#{@params['login']}&password=#{@params['password']}", 
        #             :callback => (url_for :action => :login_callback),
        #             :callback_param => "")
        # render :action => :wait
        # SyncEngine.login(@params['login'], @params['password'], (url_for :action => :login_callback) )
        # render :action => :wait
    #   rescue Rho::RhoError => e
    #     @msg = e.message
    #     render :action => :login
    #   end
    # else
    #   @msg = Rho::RhoError.err_message(Rho::RhoError::ERR_UNATHORIZED) unless @msg && @msg.length > 0
    #   render :action => :login
    # end
  end
  
  def logout
    #SyncEngine.logout
    User.find(:all).each do |user|
      user.destroy
    end
    @msg = "You have been logged out."
    render :action => :login
  end
  
  def reset
    render :action => :reset
  end
  
  def do_reset
    Rhom::Rhom.database_full_reset
    SyncEngine.dosync
    @msg = "Database has been reset."
    redirect :action => :index, :query => {:msg => @msg}
  end
  
  def do_sync
    SyncEngine.dosync
    @msg =  "Sync has been triggered."
    redirect :action => :index, :query => {:msg => @msg}
  end
end
