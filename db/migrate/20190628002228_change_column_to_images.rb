class ChangeColumnToImages < ActiveRecord::Migration[5.2]
  def change
    remove_column :images, :tag, :string
    add_column :images, :width, :integer
  end
end
