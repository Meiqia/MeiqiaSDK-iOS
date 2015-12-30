Pod::Spec.new do |s|

  s.name         = "MeiqiaSDK"
  s.version      = "v3.0.3"
  s.summary      = "美洽3.0 SDK for iOS"
  s.description  = <<-DESC
                    美洽3.0 SDK for iOS
                    MeiQiaSDK
                   DESC

  s.homepage     = "http://github.com/Meiqia/MeiqiaSDK-iOS"
  s.license      = "MIT"
  s.author             = { "MeiQia" => "dev@meiqia.com" }

  s.platform     = :ios
  s.platform     = :ios, "6.0"
  s.ios.deployment_target = "6.0"

  s.source       = { :git => "https://github.com/Meiqia/MeiqiaSDK-iOS.git", :tag => "v3.0.3" }
  s.requires_arc = true

  s.source_files  = "Meiqia-SDK-files", "Meiqia-SDK-files/*"

end
