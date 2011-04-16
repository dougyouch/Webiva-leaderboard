require  File.expand_path(File.dirname(__FILE__) + "/../../../../../spec/spec_helper")
require File.expand_path(File.dirname(__FILE__) + '/../leaderboard_spec_helper')

describe LeaderboardEntry do
  it "should require a name" do
    @entry = LeaderboardEntry.new
    @entry.should have(1).error_on(:leaderboard_board_time_id)
    @entry.should have(1).error_on(:leaderboard_user_id)
  end
  
  describe "Board & User" do
    before(:each) do
      @board = LeaderboardBoard.create :name => 'Test'
      @user = LeaderboardUser.create :name => 'AAA'
    end

    it "should be able to create an entry" do
      expect {
        @entry = LeaderboardEntry.push_entry @board, @user, 'daily'
      }.to change{ LeaderboardEntry.count }.by(1)
    end

    it "should be able to create an entry" do
      expect {
        LeaderboardEntry.update_entries @board, @user, 50
      }.to change{ LeaderboardEntry.count }.by(5)
    end

    it "should be able to create an entry" do
      time = LeaderboardBoardTime.calculate_start_time 'weekly'
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
  
  describe "Users" do
    before(:each) do
      @board = LeaderboardBoard.create :name => 'Test'
      (1..10).each do |idx|
        user = LeaderboardUser.create :name => "user #{idx}"
        LeaderboardEntry.update_entries @board, user, 10 * idx
      end
    end
    
    it "should be able to determine the users place" do
      @user = LeaderboardUser.create :name => "Test User"
      
      LeaderboardEntry.update_entries @board, @user, 5
      LeaderboardEntry.get_entries(@board, @user).each do |entry|
        entry.place.should == case entry.leaderboard_type
                              when 'alltime', 'yearly', 'monthly', 'weekly', 'daily'
                                 11
                              end
      end

      LeaderboardEntry.update_entries @board, @user, 50
      LeaderboardEntry.get_entries(@board, @user).each do |entry|
        entry.place.should == case entry.leaderboard_type
                              when 'alltime', 'yearly', 'monthly', 'weekly', 'daily'
                                 6
                              end
      end

      LeaderboardEntry.update_entries @board, @user, 50
      LeaderboardEntry.get_entries(@board, @user).each do |entry|
        entry.place.should == case entry.leaderboard_type
                              when 'alltime', 'yearly', 'monthly', 'weekly', 'daily'
                                 1
                              end
      end
    end
  end
end
