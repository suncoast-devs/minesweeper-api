class CreateGame < ActiveRecord::Migration[6.1]
  def change
    create_table :games do |t|
      t.string :game
      t.string :state
      t.string :board
      t.string :mine_locations
      t.integer :difficulty

      t.timestamps
    end
  end
end
