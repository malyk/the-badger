class PinsController < ApplicationController
  before_filter :authenticate_user!
  
  def new
    @pin = Pin.new
    @user = User.new
    @badge = Badge.find params[:badge_id]
  end
  def create
    @pin = Pin.new
    @badge = Badge.find params[:badge][:id]
    @user = User.where(:email => params[:user][:email]).one
    if @user.nil?
      flash[:alert] = "That user does not exist!"
      render :action => 'new'
      return
    end
    
    @pin.pinned_at = DateTime.now
    @pin.badge = @badge
    
    @user.pins << @pin
    
    if @pin.save and @user.save
      flash[:notice] = "You have pinned a badge on #{@user.email}!"
      if ENV['RAILS_ENV'] == 'production'
        BadgeMailer.badge_pinned_email(current_user, @user, @badge).deliver
      else
        puts "we would send an e-mail here if we were in production mode!"
      end
      redirect_to root_path
    else
      flash[:alert] = "Oh no!  Something went wrong.  Try again"
      render :action => 'new'
    end
  end
end
