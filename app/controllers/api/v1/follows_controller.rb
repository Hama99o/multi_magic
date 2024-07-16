class Api::V1::FollowsController < ApplicationController

  def follow
    followed_user = User.find(params[:followed_id])
    current_user.follow(followed_user)
    render json: { success: true, message: "You are now following #{followed_user.fullname}" }
  end

  def unfollow
    followed_user = User.find(params[:followed_id])
    current_user.unfollow(followed_user)
    render json: { success: true, message: "You unfollowed #{followed_user.fullname}" }
  end
end
