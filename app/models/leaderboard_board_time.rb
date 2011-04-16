class LeaderboardBoardTime < DomainModel
  belongs_to :leaderboard_board
  has_many :leaderboard_entries, :dependent => :delete_all

  validates_presence_of :leaderboard_board_id

  has_options :leaderboard_type, [['All-time', 'alltime'], ['Yearly', 'yearly'], ['Monthly', 'monthly'], ['Weekly', 'weekly'], ['Daily', 'daily']], :validate => true

  def self.by_board(board); self.where(:leaderboard_board_id => board.id); end
  def self.for_time(time); self.where(:started_at => time); end
  def self.by_type(type); self.where(:leaderboard_type => type); end

  def self.calculate_start_time(leaderboard_type, time=nil)
    time ||= Time.now

    case leaderboard_type
    when 'alltime'
      nil
    when 'yearly'
      time.at_beginning_of_year
    when 'monthly'
      time.at_beginning_of_month
    when 'weekly'
      time.at_beginning_of_week
    when 'daily'
      time.at_beginning_of_day
    end
  end
  
  def self.push_board_time(board, leaderboard_type, time=nil)
    starts = self.calculate_start_time(leaderboard_type, time)
    board_time = self.by_board(board).by_type(leaderboard_type).for_time(starts).first
    board_time ||= LeaderboardBoardTime.create(:leaderboard_board_id => board.id, :leaderboard_type => leaderboard_type, :started_at => starts)
  end
  
  def top_users(limit=100)
    place = 1
    self.leaderboard_entries.best_first.limit(limit).all.collect do |entry|
      entry.place = place
      place += 1
      entry
    end
  end
end
