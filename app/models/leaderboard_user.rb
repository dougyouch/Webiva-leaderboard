class LeaderboardUser < DomainModel
  has_end_user :end_user_id
  has_many :leaderboard_entries, :dependent => :delete_all
  
  before_validation :set_name
  
  validates_presence_of :name
  
  def set_name
    self.name = self.end_user.name if self.name.blank? && self.end_user
  end
  
  def update_points(board, points, time=nil)
    LeaderboardEntry.update_entries board, self, points, time
  end
end
