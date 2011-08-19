require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'helpers/browser_helper'

class SettingsController < Rho::RhoController
  include BrowserHelper
  
  def index
    @msg = @params['msg']
    render
  end

  def login
    @msg = @params['msg']
    render :action => :login, :back => '/app'
  end

  def login_callback
    puts "httpget_callback: #{@params['body']}"
    # errCode = @params['error_code'].to_i
    # if errCode == 0
      # run sync if we were successful
      #User.find(:all).destroy #remove old api_key
      #puts @params[:body]
      user = User.create(:login => @params['body']["login"], :api_key=>@params['body']["api_key"]) #add api_key
      #WebView.navigate ( url_for :action => :index, :controller => :application )
      #SyncEngine.dosync
    # else
    #   if errCode == Rho::RhoError::ERR_CUSTOMSYNCSERVER
    #     @msg = @params['error_message']
    #   end
    #     
    #   if !@msg || @msg.length == 0   
    #     @msg = Rho::RhoError.new(errCode).message
    #   end
    #   
      #WebView.navigate ( url_for :action => :login, :query => {:msg => @msg} )
    # end  
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
    SyncEngine.logout
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
