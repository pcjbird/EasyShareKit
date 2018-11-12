Pod::Spec.new do |s|
  s.name         = 'EasyShareKit'
  s.summary      = 'Easy way to parse share object from H5 page. 一种从 H5 页面获取分享对象的简便的方法。'
  s.version      = '1.0.5'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { 'pcjbird' => 'pcjbird@hotmail.com' }
  s.social_media_url = 'http://www.lessney.com'
  s.homepage     = 'https://github.com/pcjbird/EasyShareKit'
  s.platform     = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.source       = { :git => 'https://github.com/pcjbird/EasyShareKit.git', :tag => s.version.to_s }
  
  s.requires_arc = true
  s.source_files = 'EasyShareKit/*.{h,m}'
  s.public_header_files = 'EasyShareKit/*.{h}'
  s.frameworks = 'Foundation'
  
  s.dependency 'hpple'
  
end
