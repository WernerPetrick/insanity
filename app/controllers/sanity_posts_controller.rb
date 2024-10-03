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
    params.require(:post).permit(:body, :title)
  end
end
