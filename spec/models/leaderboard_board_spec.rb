require  File.expand_path(File.dirname(__FILE__) + "/../../../../../spec/spec_helper")
require File.expand_path(File.dirname(__FILE__) + '/../leaderboard_spec_helper')

describe LeaderboardBoard do
  it "should require a name" do
    @board = LeaderboardBoard.new
    @board.should have(1).error_on(:name)
  end
  
  it "should be able to create a board" do
    expect {
      @board = LeaderboardBoard.create :name => 'Test'
    }.to change{ LeaderboardBoard.count }
  end
end
