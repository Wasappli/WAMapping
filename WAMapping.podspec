Pod::Spec.new do |s|
  s.name         = "WAMapping"
  s.version      = "0.0.8"
  s.summary      = "WAMapping is a library which turns dictionary to object and vice versa. Designed for speed!"
  s.homepage     = "https://github.com/Wasappli/WAMapping"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Marian Paul" => "marian@wasapp.li" }
  s.ios.deployment_target = '7.0'
  s.watchos.deployment_target = '2.0'
  s.source       = { :git => "https://github.com/Wasappli/WAMapping.git", :tag => "0.0.8" }
  s.source_files = "Files/*.{h,m}"
  s.requires_arc = true
  s.frameworks   = "CoreData"
end
