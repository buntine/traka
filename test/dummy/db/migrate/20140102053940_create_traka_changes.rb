class CreateTrakaChanges < ActiveRecord::Migration
  def self.up
    create_table :traka_changes, :force => true do |t|
      t.string :klass
      t.string :uuid
      t.string :action_type
      t.integer :version
      t.timestamps
    end
  end

  def self.down
    drop_table :traka_changes
  end
end
