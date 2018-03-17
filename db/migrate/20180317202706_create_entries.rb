class CreateEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :entries do |t|
      t.string :premise
      t.string :conclusion
      t.string :proof

      t.timestamps
    end
  end
end
