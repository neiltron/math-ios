class ItemsScreen < PM::TableScreen
  stylesheet :main

  title "Items"
  refreshable

  def on_init
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone #To remove the cell's separator
  end

  def will_appear
    @view_is_set_up ||= set_up_view

    self.tableView.delegate = self
    self.tableView.addGestureRecognizer(UILongPressGestureRecognizer.alloc.initWithTarget(self, action:'on_longPress:'))
  end

  def set_up_view
    UIBarButtonItem.configureFlatButtonsWithColor([255, 70, 70].uicolor, highlightedColor: [255, 90, 90].uicolor, cornerRadius: 3.0)

    set_nav_bar_button :left, title: "Logout", action: :logout
    set_navigation_appearance!

    update_table_data

    true
  end

  def viewDidLoad
    super

    @root_url = App::Persistence['root_url']
    @user_id = App::Persistence['user_id']

    fetchItems
  end

  def set_navigation_appearance!
    @navigation_appearance = UINavigationBar.appearance
    @navigation_appearance.configureFlatNavigationBarWithColor "#f66".to_color
    @navigation_appearance.setTitleTextAttributes({
      UITextAttributeTextShadowColor => "#f66".to_color,
      UITextAttributeTextColor => "#fafafa".to_color
    })
  end

  def logout
    App::Persistence['access_token'] = nil
    App::Persistence['user_id'] = nil
    App::Persistence['items'] = nil

    open_root_screen LoginScreen.new(nav_bar: false)
  end

  def table_data
    if Item.all.count.nil?
      [{ cells: [] }]
    else
      items_sorted = []

      Item.all.each_with_index do |item, index|
        items_sorted.push [{ 'name' => item.name, 'id' => item.id }]

        if editing? && index == controlIndex.row
          items_sorted.push [{ 'editing' => true, 'item' => item }]
        end
      end

      [{ cells: items_sorted.map do |item, i|
          if item['editing'].nil?
            {
              title: item['name'],
              arguments: { item: item },
              cell_identifier: "MyCustomCellIdentifier",
              cell_class: UITableViewCell,
              action: :openItem,
              height: 70,
            }
          else
            @controlItem = item['item']
            values = item['item'].latestValues

            subviews = [subview(UIView.new, :backgroundView)]

            buttonView1 = UIButton.buttonWithType(UIButtonTypeCustom)
            buttonView1.addTarget( self, action: 'button_press:', forControlEvents: UIControlEventTouchUpInside )

            buttonView2 = UIButton.buttonWithType(UIButtonTypeCustom)
            buttonView2.addTarget( self, action: 'button_press:', forControlEvents: UIControlEventTouchUpInside )

            subviews.push subview(buttonView1, :button1, tag: 0, title: '+' + values[0]) unless values[0].nil?

            subviews.push subview(buttonView2, :button2, tag: 1, title: '+' + values[1]) unless values[1].nil?

            {
              cell_identifier: "ToolbarRow",
              subtitle: item['item'].id.to_s,
              cell_style: UITableViewCellStyleSubtitle,
              cell_class: ControlRowCell,
              arguments: { item: item },
              height: 55,
              subviews: subviews
            }
          end
        end
      }]
    end
  end

  def button_press sender
    #for some reason, using .tag= is having no effect
    #and button tags are defaulting to 2, 3
    tag = sender.tag - 2

    BW::HTTP.post("#{@root_url}/api/1/users/#{@user_id}/records.json", { payload: { accesskey: App::Persistence['access_token'], item_name: self.controlItem.name, amount: self.controlItem.latestValues[tag] } }) do |response|

      data = BW::JSON.parse(response.body.to_str)
      puts data.to_s

      item = Item.find_by_id(data['item'])
      item.records.create(timestamp: data['timestamp'], value: data['amount'])

      stopEditing
      update_table_data
    end
  end

  def on_longPress gestureRecognizer
    if gestureRecognizer.state == 1
      p = gestureRecognizer.locationInView(self.tableView)
      indexPath = self.tableView.indexPathForRowAtPoint(p)

      #if we're already editing, put new controlrow one step down
      if editing? && indexPath.row > controlIndex.row
        indexPath = NSIndexPath.indexPathForItem(indexPath.row - 1, inSection: indexPath.section)
      end

      startEditing indexPath unless indexPath.nil?
      update_table_data
    end
  end

  def editing?
    @editing ||= false
  end

  def stopEditing
    @editing = nil
    @controlIndex = nil
    @controlItem = nil
  end

  def startEditing controlIndex
    @editing = true
    @controlIndex = controlIndex
  end

  def controlIndex
    @controlIndex ||= nil
  end

  def controlItem
    @controlItem ||= nil
  end

  def openItem args = {}
    open ItemScreen.new(item: args[:item], nav_bar: true)

    stopEditing
    update_table_data
  end

  def on_refresh
    # refresh data
    stop_refreshing

    fetchItems
  end

  def fetchItems
    BW::HTTP.get("#{@root_url}/api/1/users/#{@user_id}/items.json", { payload: { accesskey: App::Persistence['access_token'] } }) do |response|
      Dispatch::Queue.main.async do
        if response.ok?
          items = BW::JSON.parse(response.body.to_str)
          items.each do |data|
            item = Item.find_by_id(data['id']) || Item.create(name: data['name'], id: data['id'], display_type: data['display_type'], display_frequency: data['display_frequency'])

            # item.fetchRecords
          end
        elsif response.status_code.to_s =~ /40\d/
          open_root_screen LoginScreen.new(nav_bar: false)
        else
          open_root_screen LoginScreen.new(nav_bar: false)
        end

        update_table_data
      end
    end
  end
end

class ControlRowCell < PM::TableViewCell
  attr_accessor :background_view, :label_view, :value_view

  stylesheet :main

  PADDING = 5
  LEFT_PERCENTAGE = 42

  def initWithStyle(style, reuseIdentifier:cell_identifier)
    cell = super

    cell
  end
end

Teacup::Stylesheet.new :main do  # <= stylesheet name
  style :backgroundView,
    frame: [[0,0],
            ['100%', 60]],
    backgroundColor: '#e88'.to_color

  style :buttons,  # <= style name
    font: UIFont.systemFontOfSize(16),
    backgroundColor: '#fafafa'.to_color,
    titleColor: '#333'.to_color,
    # text: latest_values[0].to_s || "wut",
    layer: {
      cornerRadius: 4.0,
    }

  style :button1, extends: :buttons,
    frame: [[10, 10],
            ["20%", 35]]

  style :button2, extends: :buttons,
    frame: [["20% + 20", 10],
            ["20%", 35]]

end
