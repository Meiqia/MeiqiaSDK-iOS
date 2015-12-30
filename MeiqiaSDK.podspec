Pod::Spec.new do |s|

  s.name         = "MeiqiaSDK"
  s.version      = "3.0.1"
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

  s.source       = { :git => "https://github.com/Meiqia/MeiqiaSDK-iOS.git", :tag => "3.0.1" }
  s.requires_arc = true

  s.subspec 'MQChatViewController' do |ss|
    ss.source_files = 'Meiqia-SDK-Demo/MQChatViewController/**/*.{h,m}'
    ss.public_header_files = 'Meiqia-SDK-Demo/MQChatViewController/**/*.{h,m}'
    ss.resources = 'Meiqia-SDK-Demo/MQChatViewController/Assets/MQChatViewAsset.bundle'
    ss.vendored_frameworks = "Meiqia-SDK-Demo/MeiQiaSDK.framework"
#    ss.vendored_libraries = "Meiqia-SDK-Demo/MQChatViewController/Vendors/MLAudioRecorder/amr_en_de/lib/*.a"
    ss.frameworks = "AVFoundation", "CoreTelephony", "SystemConfiguration", "MobileCoreServices"
    ss.libraries = "sqlite3", "icucore"
  end

  s.subspec 'MeiqiaSDKViewInterface' do |ss|
    ss.source_files = 'Meiqia-SDK-Demo/MeiqiaSDKViewInterface/*.{h,m}'
    ss.public_header_files = 'Meiqia-SDK-Demo/MeiqiaSDKViewInterface/*.{h,m}'
  end

end
