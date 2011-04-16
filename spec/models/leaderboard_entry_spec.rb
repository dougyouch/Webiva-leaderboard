require  File.expand_path(File.dirname(__FILE__) + "/../../../../../spec/spec_helper")
require File.expand_path(File.dirname(__FILE__) + '/../leaderboard_spec_helper')

describe LeaderboardEntry do
  it "should require a name" do
    @entry = LeaderboardEntry.new
    @entry.should have(1).error_on(:leaderboard_board_id)
    @entry.should have(1).error_on(:leaderboard_user_id)
    @entry.should have(1).error_on(:leaderboard_type)
  end
  
  describe "Board & User" do
    before(:each) do
      @board = LeaderboardBoard.create :name => 'Test'
      @user = LeaderboardUser.create :name => 'AAA'
    end

    it "should be able to create a entry" do
      expect {
        LeaderboardEntry.update_entries @board, @user, 50
      }.to change{ LeaderboardEntry.count }.by(5)
    end

    it "should be able to create a entry" do
      time = LeaderboardEntry.calculate_start_time 'weekly'
      expect {
        LeaderboardEntry.update_entries @board, @user, 50, time
      }.to change{ LeaderboardEntry.count }.by(5)
      
      LeaderboardEntry.get_entries(@board, @user, time).each do |entry|
        entry.points.should == case entry.leaderboard_type
                               when 'alltime', 'yearly', 'monthly', 'weekly', 'daily'
                                 50
                               end
      end
      
      expect {
        LeaderboardEntry.update_entries @board, @user, 50, time
      }.to change{ LeaderboardEntry.count }.by(0)

      LeaderboardEntry.get_entries(@board, @user, time).each do |entry|
        entry.points.should == case entry.leaderboard_type
                               when 'alltime', 'yearly', 'monthly', 'weekly', 'daily'
                                 100
                               end
      end
      
      time += 1.day
      expect {
        LeaderboardEntry.update_entries @board, @user, 50, time
      }.to change{ LeaderboardEntry.count }.by(1)

      LeaderboardEntry.get_entries(@board, @user, time).each do |entry|
        entry.points.should == case entry.leaderboard_type
                               when 'alltime', 'yearly', 'monthly', 'weekly'
                                 150
                               when 'daily'
                                 50
                               end
      end
      
      time += 1.week
      expect {
        LeaderboardEntry.update_entries @board, @user, 50, time
      }.to change{ LeaderboardEntry.count }.by(2)

      LeaderboardEntry.get_entries(@board, @user, time).each do |entry|
        entry.points.should == case entry.leaderboard_type
                               when 'alltime', 'yearly', 'monthly'
                                 200
                               when 'weekly', 'daily'
                                 50
                               end
      end
      
      time += 1.month
      expect {
        LeaderboardEntry.update_entries @board, @user, 50, time
      }.to change{ LeaderboardEntry.count }.by(3)

      LeaderboardEntry.get_entries(@board, @user, time).each do |entry|
        entry.points.should == case entry.leaderboard_type
                               when 'alltime', 'yearly'
                                 250
                               when 'monthly', 'weekly', 'daily'
                                 50
                               end
      end

      time += 1.year
      expect {
        LeaderboardEntry.update_entries @board, @user, 50, time
      }.to change{ LeaderboardEntry.count }.by(4)

      LeaderboardEntry.get_entries(@board, @user, time).each do |entry|
        entry.points.should == case entry.leaderboard_type
                               when 'alltime'
                                 300
                               when 'yearly', 'monthly', 'weekly', 'daily'
                                 50
                               end
      end
    end
  end
end
