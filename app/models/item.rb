class Item
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter

  columns name:               :string,
          id:                 :string,
          display_type:       :string,
          display_frequency:  :string,
          updated_at:         :date,
          created_at:         :date

  has_many :records

  def latestValues
    values = []

    self.records.all.reverse_each do |record|
      values.push record.value unless values.include?(record.value) || record.value.to_i == 0

      break if values.count >= 2
    end

    values
  end

  def fetchRecords
    @root_url = App::Persistence['root_url']
    @user_id = App::Persistence['user_id']

    #start fresh
    self.records.each { |rec| rec.delete } if self.records.count > 0


    BW::HTTP.get("#{@root_url}/api/1/users/#{@user_id}/items/#{self.id}/records.json", { payload: { accesskey: App::Persistence['access_token'] } }) do |response|
      if response.ok?
        data = BW::JSON.parse(response.body.to_str)

        data['values'].each do |timestamp, value|
          self.records.create(timestamp: timestamp, value: value)
        end

        App.notification_center.post 'UpdateItem' + self.id.to_s, nil
      else
        open_root_screen LoginScreen.new(nav_bar: false)
      end
    end
  end
end