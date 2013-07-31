class AppDelegate < PM::Delegate

  status_bar false, animation: :none

  def on_load(app, options)
    App.notification_center.observe 'AccessTokenAcquired' do |notification|
      accessTokenAcquired
    end

    setup_defaults
    appearance_defaults

    #Splash Screen
    # this next line is a little messy, but it gives the idea for handling iphone 5
    image = (568 == UIScreen.mainScreen.bounds.size.height) ? ("Default-568h") : ("Default")
    image_view = UIImageView.alloc.initWithImage(UIImage.imageNamed(image))


    if App::Persistence['access_token'].nil?
      open LoginScreen.new(nav_bar: false)
    else
      open ItemsScreen.new(nav_bar: true)
    end

    # fade out splash image
    fade_out_timer = 1.0
    UIView.transitionWithView(@window, duration:fade_out_timer, options:UIViewAnimationOptionTransitionNone, animations: lambda {image_view.alpha = 0}, completion: lambda do |finished|
      image_view.removeFromSuperview
      image_view = nil
      UIApplication.sharedApplication.setStatusBarHidden(false, animated:false)
    end)

    true
  end

  def appearance_defaults
    UIApplication.sharedApplication.setStatusBarHidden false, animated:false
    UINavigationBar.appearance.tintColor = "#f66".to_color
    UIToolbar.appearance.tintColor = "f66".to_color
  end

  def setup_defaults
    App::Persistence['root_url'] ||= 'https://mathematics.io'
    App::Persistence['client_id'] ||= '7ghkk41f8mxdmr24ymup25wjw'
  end

  def accessTokenAcquired
    open ItemsScreen.new(nav_bar: true)
  end
end
