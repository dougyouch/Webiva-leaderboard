class LeaderboardEntry < DomainModel
  attr_accessor :place

  belongs_to :leaderboard_board_time
  belongs_to :leaderboard_user

  validates_presence_of :leaderboard_board_time_id
  validates_presence_of :leaderboard_user_id

  def self.get_entries(board, user, time=nil)
    LeaderboardBoardTime.leaderboard_type_options.collect do |leaderboard_type, display|
      self.push_entry board, user, leaderboard_type, time
    end
  end

  def self.get_entry_ids(board, user, time=nil)
    return self.get_entries(board, user, time).collect(&:id) if time

    time = Time.now

    entries = DataCache.get_remote 'LeaderboardBoard', board.id.to_s, user.id.to_s
    return entries if entries

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
    board_time = LeaderboardBoardTime.push_board_time board, leaderboard_type, time
    entry = LeaderboardEntry.where(:leaderboard_board_time_id => board_time.id, :leaderboard_user_id => user.id).first
    entry ||= LeaderboardEntry.create(:leaderboard_board_time_id => board_time.id, :leaderboard_user_id => user.id)
  end
  
  def board_scope
    LeaderboardEntry.where(:leaderboard_board_time_id => self.leaderboard_board_time_id)
  end
  
  def leaderboard_type
    self.leaderboard_board_time.leaderboard_type if self.leaderboard_board_time
  end

  def started_at
    self.leaderboard_board_time.started_at if self.leaderboard_board_time
  end

  def leaderboard_board
    self.leaderboard_board_time.leaderboard_board if self.leaderboard_board_time
  end

  def place(limit=1000)
    @place ||= self.board_scope.where('points >= ? && leaderboard_user_id != ?', self.points, self.leaderboard_user_id).order('points DESC, updated_at DESC').limit(limit).count + 1
  end
end
