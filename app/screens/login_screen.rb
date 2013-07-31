class LoginScreen < PM::Screen
  title "Login"

  def on_load
    set_appearance!

    self.view = UIWebView.alloc.init
    self.view.delegate = self

    @root_url = App::Persistence['root_url']
    @client_id = App::Persistence['client_id']

    url = NSURL.URLWithString("#{@root_url}/oauth/authorize?response_type=token&client_id=#{@client_id}&redirect_uri=math://oauth.io&scope=read+write")
    self.view.loadRequest NSURLRequest.requestWithURL(url)
  end

  def set_appearance!
    UIBarButtonItem.configureFlatButtonsWithColor([255, 70, 70].uicolor, highlightedColor: [255, 90, 90].uicolor, cornerRadius: 3.0)

    @navigation_appearance = UINavigationBar.appearance
    @navigation_appearance.configureFlatNavigationBarWithColor "#f66".to_color
    @navigation_appearance.setTitleTextAttributes({
      UITextAttributeTextShadowColor => "#f66".to_color,
      UITextAttributeTextColor => "#fafafa".to_color
    })
  end

  def webView(web, shouldStartLoadWithRequest: request, navigationType: type)
    if request.URL.scheme == 'math'
      parseOAuthResponse request.URL.query
      fetchUserProfile

      false
    end

    true
  end

  def parseOAuthResponse query_string
    puts query_string
    chunks = query_string.componentsSeparatedByString("&")
    params = {}

    chunks.each do |chunk|
      chunk = chunk.componentsSeparatedByString("=")

      params[chunk[0]] = chunk[1]
    end

    App::Persistence['access_token'] = params['access_token']
  end

  def fetchUserProfile
    BW::HTTP.get("#{@root_url}/api/1/users/profile.json", { payload: { accesskey: App::Persistence['access_token'] } }) do |response|

      if response.ok?
        json = BW::JSON.parse(response.body.to_str)
        App::Persistence['user_id'] = json['id']
      elsif response.status_code.to_s =~ /40\d/
        App.alert("Login failed")
      else
        App.alert(response.error_message)
      end

      App.notification_center.post 'AccessTokenAcquired'
    end
  end
end