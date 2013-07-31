class ItemScreen < PM::TableScreen
  attr_accessor :item

  layout do
    @item_label = subview(UILabel, :label)
  end

  def on_init
    @root_url = App::Persistence['root_url']
    @user_id = App::Persistence['user_id']

    @item = Item.where(:id).eq(self.item['id']).first
    @item.fetchRecords

    self.setTitle @item.name
  end

  def will_appear
    @view_is_set_up ||= set_up_view

    @headerView = UIWebView.alloc.initWithFrame([[0,0], [320, 200]])
    @headerView.delegate = self
    @headerView.scrollView.scrollEnabled = false
    @headerView.scrollView.bounces = false

    @headerView.loadRequest(NSURLRequest.requestWithURL(NSURL.fileURLWithPath(NSBundle.mainBundle.pathForResource('graphview/index', ofType:'html'))))

    self.table_view.tableHeaderView = @headerView
  end

  def webViewDidFinishLoad webview
    values = @item.records.all.map do |record|
      '[' + record.timestamp.to_s + ', ' + record.value.to_s + ']'
    end

    webview.stringByEvaluatingJavaScriptFromString('var graph_data = { values: [' + values.join(',') + '] };')
    webview.stringByEvaluatingJavaScriptFromString('var item_id = "' + @item.id + '";')
    webview.stringByEvaluatingJavaScriptFromString('var display_type = "' + @item.display_frequency.capitalizedString + ' ' + @item.display_type.capitalizedString + '";')
    webview.stringByEvaluatingJavaScriptFromString('drawGraph()')

  end

  def set_up_view
    App.notification_center.observe 'UpdateItem' + @item.id.to_s do |notification|
      puts 'updateitem ' + @item.id.to_s
      update_table_data
      webViewDidFinishLoad(@headerView)
    end

    set_nav_bar_button :right, title: "+", action: :add_record, type: UIBarButtonSystemItemAdd

    true
  end

  def close_modal_tapped
    close
  end

  def add_record
    open AddRecordScreen.new(item: self.item, nav_bar: true)
  end

  def table_data
    if @item.records.count <= 0
      [{ cells: [] }]
    else
      records_sorted = {}

      @item.records.all.reverse_each.with_index do |item, index|
        date = NSDate.dateWithTimeIntervalSince1970 item.timestamp

        date_formatted = date.string_with_format('M-d-Y')
        time_formatted = date.string_with_format('h:mm a')

        records_sorted[date_formatted] ||= []

        records_sorted[date_formatted].push [time_formatted, item.value]
      end

      records_sorted.each_with_index.map do |date, i|
        {
          title: date[0].to_s,
          cells: date[1].map do |time, value|
            {
              title: value.to_s,
              subtitle: time.to_s,
              cell_identifier: "MyCustomCellIdentifier",
              cell_style: UITableViewCellStyleSubtitle,
              cell_class: PM::TableViewCell,
              height: 70
            }
          end
        }
      end
    end
  end

  def tableView(tableView, viewForHeaderInSection: section)
    section_title = self.tableView(tableView, titleForHeaderInSection: section)

    UIView.alloc.init.tap do |view|
      view.backgroundColor = '#f88'.to_color

      label = UILabel.alloc.init
      label.frame = CGRectMake(10, -10, 320, 40)
      label.backgroundColor = 'clear'.to_color
      label.textColor = '#fff'.to_color
      label.text = section_title
      label.font = UIFont.systemFontOfSize(14)

      view.addSubview(label)
    end
  end

  def on_refresh
    # refresh data
    stop_refreshing
    update_table_data
  end
end