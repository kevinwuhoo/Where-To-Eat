class PagesController < ApplicationController
  def index
    env['HTTP_X_REAL_IP'] ||= env['REMOTE_ADDR']
    @ip = env['HTTP_X_REAL_IP']
  end

end
