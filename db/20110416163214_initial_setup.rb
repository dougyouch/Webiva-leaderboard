class InitialSetup < ActiveRecord::Migration
  def self.up
    create_table :leaderboard_boards, :force => true do |t|
      t.string :name
    end

    # separate users table, just incase anonymous users can get on the leader board
    create_table :leaderboard_users, :force => true do |t|
      t.string :name
      t.integer :end_user_id
    end

    add_index :leaderboard_users, :end_user_id, :name => 'leaderboard_users_idx'
    
    create_table :leaderboard_entries, :force => true do |t|
      t.integer :leaderboard_board_id
      t.integer :leaderboard_user_id
      t.string :leaderboard_type
      t.datetime :started_at # when the leaderboard started
      t.integer :points, :default => 0
      t.timestamps
    end
    
    add_index :leaderboard_entries, [:leaderboard_board_id, :leaderboard_user_id], :name => 'leaderboard_entries_board_idx'
  end

  def self.down
    drop_table :leaderboard_boards
    drop_table :leaderboard_users
    drop_table :leaderboard_entries
  end
end
