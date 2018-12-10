Pod::Spec.new do |s|
  s.name         = "YJWaveProgressView"
  s.version      = "1.1.0"
  s.summary      = "一款圆形水波进度控件."
  s.description  = <<-DESC
	一款圆形水波进度控件，高度支持可定制开发，支持自动布局
                   DESC
  s.homepage     = "https://github.com/mcyj1314/YJWaveProgressView"
  s.license      = "MIT"
  s.author       = { "Jeremiah" => "971175049@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/mcyj1314/YJWaveProgressView.git", :tag => "1.1.0" }
  s.source_files = "YJWaveProgressView", "YJWaveProgressView/**/*.{h,m}"
  s.requires_arc = true

end
