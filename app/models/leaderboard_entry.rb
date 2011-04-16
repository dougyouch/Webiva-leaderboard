class LeaderboardEntry < DomainModel
  belongs_to :leaderboard_board
  belongs_to :leaderboard_user

  validates_presence_of :leaderboard_board_id
  validates_presence_of :leaderboard_user_id

  has_options :leaderboard_type, [['All-time', 'alltime'], ['Yearly', 'yearly'], ['Monthly', 'monthly'], ['Weekly', 'weekly'], ['Daily', 'daily']], :validate => true
  
  def self.by_board(board); self.where(:leaderboard_board_id => board.id); end
  def self.by_user(user); self.where(:leaderboard_user_id => user.id); end
  def self.for_time(time); self.where(:started_at => time); end
  def self.by_type(type, time=nil)
    conditions = {:leaderboard_type => type}
    conditions[:started_at] = self.calculate_start_time(type, time) if time
    self.where conditions
  end

  def self.current_time
    Time.now
  end

  def self.calculate_start_time(leaderboard_type, time=nil)
    time ||= self.current_time

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

  def self.get_entries(board, user, time=nil)
    time ||= self.current_time
    self.leaderboard_type_options.collect do |leaderboard_type, display|
      self.push_entry board, user, leaderboard_type, time
    end
  end

  def self.get_entry_ids(board, user, time=nil)
    entries = DataCache.get_remote 'LeaderboardBoard', board.id.to_s, user.id.to_s
    return entries if entries

    time ||= self.current_time
    entries = self.get_entries(board, user, time).collect(&:id)
    
    expires = (time + 1.day).at_beginning_of_day.to_i - time.to_i
    DataCache.put_remote 'LeaderboardBoard', board.id.to_s, user.id.to_s, entries, expires
    
    entries
  end

  def self.update_entries(board, user, points, time=nil)
    entries = self.get_entry_ids board, user, time
    self.connection.update "UPDATE leaderboard_entries SET points = points + #{points}, updated_at = \"#{Time.now.to_s(:db)}\" WHERE id IN(#{entries.join(',')})"
  end
  
  def self.push_entry(board, user, leaderboard_type, time=nil)
    starts = self.calculate_start_time(leaderboard_type, time)
    entry = self.by_board(board).by_user(user).by_type(leaderboard_type).for_time(starts).first
    entry ||= board.leaderboard_entries.create(:leaderboard_user_id => user.id, :leaderboard_type => leaderboard_type, :started_at => starts)
  end
end
