class CreateGame < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :game
      t.string :state
      t.string :board
      t.string :mine_locations
      t.integer :difficulty
    end
  end
end
