class SanityPostsController < ApplicationController
  def index
    query = '*[_type == "post"]{ _id, title, body, image }'
    response = SanityPostsHelper.fetch(query)
    @posts = response['result'] if response
  end
  
  def show 
    post_id = params[:id]
    query = '*[_type == "post" && _id == $post_id]{ _id, title, body, image }'
    response = SanityPostsHelper.fetch(query, { post_id: post_id })
    @post = response['result'].first if response
  end
  
end
