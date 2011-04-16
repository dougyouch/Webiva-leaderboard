class LeaderboardBoard < DomainModel
  has_many :leaderboard_entries
  
  validates_presence_of :name
end
