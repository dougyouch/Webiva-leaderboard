class LeaderboardBoard < DomainModel
  belongs_to :content, :polymorphic => true
  has_many :leaderboard_board_times, :dependent => :destroy

  validates_presence_of :name
end
