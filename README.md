Math for iPhone
====

iPhone client for [Math](http://mathematics.io), an easy way to keep track of anything (that can have a number assigned to it).

## Requirements

- [RubyMotion](http://rubymotion.com) license
- OSX 10.6+
- Xcode
- iOS SDK & iOS developer program membership (to install on device)
- A [Math](http://mathematics.io) account. Or, if you're running your own Math instance, make sure to change the root_url in app_delegate.rb to match your server.


## Setup

    git clone git@github.com:neiltron/math-ios.git
    cd math-ios

    sudo gem install cocoapods
    pod setup

    bundle install
    bundle exec rake


## Install on device

Check out the following guides for help on deploying to your device:

http://www.rubymotion.com/developer-center/guides/project-management/#_install_on_device
http://paulsturgess.co.uk/blog/2013/05/10/using-rubymotion-to-provision-an-app-onto-your-iphone/


## Contribute

Feel free to create [an issue](https://github.com/neiltron/math-ios/issues) if you have any problems. If you'd like to contribute fixes or changes, please fork the repository and create a pull request. If you aren't sure where to start or need help implementing something, you can create an issue to discuss it or contact me directly.

## Contact

 - http://twitter.com/realtron
 - [neil@descend.org](mailto:neil@descend.org)


## License

Released under the Modified BSD License. Free to use, modify, and distribute (with restrictions).  Check the [LICENSE](https://github.com/neiltron/math-ios/blob/master/LICENSE) for more information.
