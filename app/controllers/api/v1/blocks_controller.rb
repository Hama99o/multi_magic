class Api::V1::BlocksController < ApplicationController

  def block
    blocked_user = User.find(params[:blocked_id])
    current_user.block(blocked_user)
    render json: { success: true, message: "#{blocked_user.fullname} has been blocked." }
  end

  def unblock
    blocked_user = User.find(params[:blocked_id])
    current_user.unblock(blocked_user)
    render json: { success: true, message: "#{blocked_user.fullname} has been unblocked." }
  end
end