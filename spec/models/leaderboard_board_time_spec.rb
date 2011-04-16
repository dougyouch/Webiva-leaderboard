require  File.expand_path(File.dirname(__FILE__) + "/../../../../../spec/spec_helper")
require File.expand_path(File.dirname(__FILE__) + '/../leaderboard_spec_helper')

describe LeaderboardBoardTime do
  it "should require a name" do
    @board_time = LeaderboardBoardTime.new
    @board_time.should have(1).error_on(:leaderboard_board_id)
    @board_time.should have(1).error_on(:leaderboard_type)
  end
  
  describe "Board" do
    before(:each) do
      @board = LeaderboardBoard.create :name => 'Test'
    end

    it "should be able to create a board" do
      expect {
        @board_time = LeaderboardBoardTime.create :leaderboard_board_id => @board.id, :leaderboard_type => 'daily'
      }.to change{ LeaderboardBoardTime.count }
    end
  end
end
