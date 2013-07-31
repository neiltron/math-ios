class AddRecordScreen < PM::FormotionScreen
  attr_accessor :item

  title "Create a Record"

  def will_appear
    puts 'self'
    puts self.item

    set_nav_bar_button :right, title: "Save", action: :submit, type: UIBarButtonItemStyleDone

    set_attributes self.view,
      background_color: '#f66'.to_color
  end

  def table_data
    {
      sections: [{
        title: "Add a Record",
        rows: [{
          title: "Item",
          key: :item,
          type: :picker,
          items: Item.all.map { |item| item.name },
          value: ""
        }, {
          title: "",
          key: :value,
          placeholder: "12345",
          type: :number
        }],
      }]
    }
  end

  def close_modal_tapped
    close
  end

  def submit
    @root_url = App::Persistence['root_url']
    @user_id = App::Persistence['user_id']

    data = self.form.render

    item = data[:item]
    value = data[:value]

    BW::HTTP.post(
      "#{@root_url}/api/1/users/#{@user_id}/records.json",
      {
        payload: {
          accesskey: App::Persistence['access_token'],
          item_name: item,
          amount: value
        }
      }) do |response|

      if response.ok?
        close
      elsif response.status_code.to_s =~ /40\d/
        App.alert("Login failed")
        close
      else
        App.alert(response.error_message)
      end
    end
  end
end