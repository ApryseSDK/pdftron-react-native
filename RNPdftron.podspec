require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNPdftron"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  RNPdftron
                   DESC
  s.homepage     = "https://github.com/PDFTron/pdftron-react-native"
  s.license      = "MIT"
  # s.license    = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = { "author" => "author@domain.cn" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/PDFTron/pdftron-react-native.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m}"
  s.requires_arc = true

  s.dependency 'React'
  s.dependency 'PDFNet'

  s.pod_target_xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/PDFNet"'
  }
end

  