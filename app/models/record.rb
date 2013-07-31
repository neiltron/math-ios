class Record
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter

  columns value:       :string,
          timestamp:    :integer,
          updated_at:   :date,
          created_at:   :date

  belongs_to :item
end