# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'
Bundler.require

require 'sugarcube-gestures'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Math'
  app.identifier = 'com.mathematics.math'
  app.icons = ['icon_iphone.png']
  app.prerendered_icon = true
  app.info_plist['CFBundleURLTypes'] = [
    { 'CFBundleURLName' => 'com.mathematics.math' }
  ]

  app.pods do
    pod 'FlatUIKit'
    pod 'AFNetworking'
  end
end
