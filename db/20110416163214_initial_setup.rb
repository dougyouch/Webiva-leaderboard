class InitialSetup < ActiveRecord::Migration
  def self.up
    create_table :leaderboard_boards, :force => true do |t|
      t.string :name
      t.string :permalink
      t.string :content_type
      t.integer :content_id
    end

    # separate users table, just incase anonymous users can get on the leader board
    create_table :leaderboard_users, :force => true do |t|
      t.string :name
      t.integer :end_user_id
    end

    add_index :leaderboard_users, :end_user_id, :name => 'leaderboard_users_idx'
 
    create_table :leaderboard_board_times, :force => true do |t|
      t.integer :leaderboard_board_id
      t.string :leaderboard_type
      t.datetime :started_at # when the leaderboard started
    end

    add_index :leaderboard_board_times, [:leaderboard_board_id, :leaderboard_type, :started_at], :name => 'leaderboard_board_times_idx'

    create_table :leaderboard_entries, :force => true do |t|
      t.integer :leaderboard_board_time_id
      t.integer :leaderboard_user_id
      t.integer :points, :default => 0
      t.timestamps
    end
    
    add_index :leaderboard_entries, [:leaderboard_board_time_id, :leaderboard_user_id], :name => 'leaderboard_entries_idx'
  end

  def self.down
    drop_table :leaderboard_boards
    drop_table :leaderboard_users
    drop_table :leaderboard_board_times
    drop_table :leaderboard_entries
  end
end
