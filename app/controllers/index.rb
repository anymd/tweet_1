get '/' do
  # Look in app/views/index.erb
  erb :index
end

get '/:username' do
  erb :index
end

get '/:username/tweets' do
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
  erb :_tweets, layout: false
end

get '/:username/follower_count' do
  @user = Twitter.user(params[:username])
  erb :_follower_count, layout: false
end

helpers do

  def fetch_tweets!
    sleep 5
    Twitter.user_timeline("#{@user.username}", :count => 10).each do |status|
      Tweet.create(:text => status.text,
                   :twitter_user_id => @user.id,
                   :tweet_time => status.created_at)
    end
  end

  def tweets_stale?
    @later_time_difference = Time.now - @user.tweets[0].tweet_time
    @earlier_time_difference = @user.tweets[0].tweet_time - @user.tweets[1].tweet_time
    @later_time_difference > @earlier_time_difference
  end

  def delete_tweets!
    @user.tweets.destroy_all 
  end

end
