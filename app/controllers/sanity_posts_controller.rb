class SanityPostsController < ApplicationController
  
  def index
    query = '*[_type == "post"]{ _id, title, body, image }'
    response = SanityPostsHelper.fetch(query)
    @posts = response['result'] if response
  end
  
  def show 
    post_id = params[:id]
    query = "*[_type == 'post' && _id == $post_id]{ _id, title, body, image }"
  
    Rails.logger.debug "Sanity Query: #{query}, Post ID: #{post_id}"
    response = SanityPostsHelper.fetch(query, { post_id: post_id })
    Rails.logger.debug "Sanity Response: #{response}"
  
    if response && response['result'].present? && response['result'].any?
      @post = response['result'].first
    else
      @post = nil
      Rails.logger.warn "No post found for ID: #{post_id}"
    end
  end
  
  def new
  end
  
  def create
    Rails.logger.debug("Received parameters: #{params.inspect}")
    document_params = {
      _type: 'post',
      title: params[:title],
      slug: {
      _type: 'slug',
      current: params[:slug]
    },
    body: [
      {
        _type: 'block',
        _key: SecureRandom.uuid,
        children: [
          {
            _type: 'span',
            text: params[:body]
          }
        ]
      }
    ]}

    response = SanityPostsHelper.create_document(document_params)
    
    if response && response['results']
      flash[:notice] = 'Post created successfully!'
      redirect_to sanity_posts_path
    else
      flash[:alert] = "Failed to create post: #{response.inspect}"
      render :new
    end
  end

  private

  def post_params_from_request
    params.require(:post).permit(:body, :title, :slug)
  end
end
