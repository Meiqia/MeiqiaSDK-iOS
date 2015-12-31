Pod::Spec.new do |s|

  s.name         = "MeiqiaSDK"
  s.version      = "3.0.3"
  s.summary      = "美洽3.0 SDK for iOS"
  s.description  = <<-DESC
                    美洽3.0 SDK for iOS
                    MeiQiaSDK
                   DESC

  s.homepage     = "https://github.com/Meiqia/MeiqiaSDK-iOS"
  s.license      = "MIT"
  s.author             = { "MeiQia" => "dev@meiqia.com" }

  s.platform     = :ios
  s.platform     = :ios, "6.0"
  s.ios.deployment_target = "6.0"

  s.source       = { :git => "https://github.com/Meiqia/MeiqiaSDK-iOS.git", :tag => "v3.0.3" }

  s.source_files  = "Meiqia-SDK-files/**/*.{h,m}"

  s.resources = "Meiqia-SDK-files/MQChatViewController/Assets/MQChatViewAsset.bundle"

  s.vendored_frameworks = "Meiqia-SDK-files/MeiQiaSDK.framework"

  s.vendored_libraries = "Meiqia-SDK-files/MQChatViewController/Vendors/MLAudioRecorder/amr_en_de/lib/*.a"

  s.frameworks = "AVFoundation", "CoreTelephony", "SystemConfiguration", "MobileCoreServices"

  s.libraries = "sqlite3", "icucore"

  s.license      = "MIT"

end
