class CreateTrakaChanges < ActiveRecord::Migration
  def change
    create_table :traka_changes do |t|
      t.string :klass
      t.string :uuid
      t.string :action_type
      t.integer :version

      t.timestamps
    end
  end
end
