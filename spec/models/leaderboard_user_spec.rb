require  File.expand_path(File.dirname(__FILE__) + "/../../../../../spec/spec_helper")
require File.expand_path(File.dirname(__FILE__) + '/../leaderboard_spec_helper')

describe LeaderboardUser do
  it "should require a name" do
    @user = LeaderboardUser.new
    @user.should have(1).error_on(:name)
  end
  
  it "should be able to create a user" do
    expect {
      @user = LeaderboardUser.create :name => 'First Last'
    }.to change{ LeaderboardUser.count }
  end

  it "should be able to create a user" do
    @end_user = EndUser.push_target 'test@test.dev', :first_name => 'First', :last_name => 'Last'
    expect {
      @user = LeaderboardUser.create :end_user_id => @end_user.id
    }.to change{ LeaderboardUser.count }
    @user.name.should == 'First Last'
  end
end
