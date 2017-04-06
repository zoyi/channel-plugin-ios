Pod::Spec.new do |s|  
  s.name              = 'CHPlugin'
  s.version           = '0.1.7'
  s.summary           = 'Channel plugin for iOS'
  s.homepage          = 'http://www.channel.io'

  s.author            = { 'Zoyi' => 'eng@zoyi.co' }
  s.license           = { :type => 'Apache-2.0', :file => 'LICENSE' }

  s.platform          = :ios
  s.source            = { :git => 'https://github.com/zoyi/channel-plugin-ios.git', :tag => s.version }
	
	s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.ios.vendored_frameworks = 'CHPlugin.framework'

  s.dependency 'SlackTextViewController'
  s.dependency 'MGSwipeTableCell'
  s.dependency 'M13ProgressSuite'
  s.dependency 'MWPhotoBrowser'
  s.dependency 'SVProgressHUD'
end 
