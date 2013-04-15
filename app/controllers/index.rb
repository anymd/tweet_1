get '/' do
  # Look in app/views/index.erb
  erb :index
end

get '/:username' do

  @user = TwitterUser.find_or_create_by_username(params[:username])
  
  if @user.tweets.empty?
    fetch_tweets!
  else
    if tweets_stale?
      delete_tweets!
      fetch_tweets!
    end
  end  

  @tweets = @user.tweets.limit(10)  

  erb :index
end

helpers do

  def fetch_tweets!
    Twitter.user_timeline("#{@user.username}", :count => 10).each do |status|
      Tweet.create(:text => status.text,
                   :twitter_user_id => @user.id,
                   :tweet_time => status.created_at)
    end
     
  end

  def tweets_stale?
    # Time.now - @user.tweets.last.created_at >= 20
    
    @later_time_difference = Time.now - @user.tweets[0].tweet_time
    @earlier_time_difference = @user.tweets[0].tweet_time - @user.tweets[1].tweet_time
    @later_time_difference > @earlier_time_difference
  end

  def delete_tweets!
    #@user.tweets.delete_all 
    @user.tweets.destroy_all 
  end

end
