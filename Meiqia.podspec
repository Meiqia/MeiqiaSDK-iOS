#
# Be sure to run `pod lib lint MeiqiaSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Meiqia"
  s.version          = "3.1.4"
  s.summary          = "美洽官方 SDK for iOS"
  s.description      = "美洽官方的 iOS SDK"

  s.homepage         = "https://github.com/Meiqia/MeiqiaSDK-iOS"
  s.license          = 'MIT'
  s.author           = { "ijinmao" => "340052204@qq.com" }
  s.source           = { :git => "https://github.com/Meiqia/MeiqiaSDK-iOS.git", :tag => "v3.1.4" }
  s.social_media_url = "https://meiqia.com"

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  # s.source_files = 'Meiqia-SDK-files/MeiqiaSDKViewInterface/*.{h,m}', 'Meiqia-SDK-files/MQChatViewController/**/*.{h,m,mm,cpp}'

  s.resource_bundles = {
    'MeiqiaSDK' => ['Meiqia-SDK-files/MQChatViewController/Assets/MQChatViewAsset.bundle']
  }
  s.subspec 'MQChatViewController' do |ss|
    ss.dependency = 'Meiqia/MeiqiaSDKViewInterface'
    ss.source_files  = 'Meiqia-SDK-files/MQChatViewController/**/*.{h,m,mm,cpp}'
  end
  s.subspec 'MeiqiaSDKViewInterface' do |ss|
    ss.dependency = 'Meiqia/MQChatViewController'
    ss.source_files  = 'Meiqia-SDK-files/MeiqiaSDKViewInterface/*.{h,m}'
  end
  s.vendored_frameworks = 'Meiqia-SDK-files/MeiQiaSDK.framework'
  s.frameworks =  'AVFoundation', 'CoreTelephony', 'SystemConfiguration', 'MobileCoreServices'
  s.libraries  =  'sqlite3', 'icucore'
  s.vendored_libraries = 'Meiqia-SDK-files/MQChatViewController/Vendors/MLAudioRecorder/amr_en_de/lib/libopencore-amrnb.a', 'Meiqia-SDK-files/MQChatViewController/Vendors/MLAudioRecorder/amr_en_de/lib/libopencore-amrwb.a'
  s.preserve_path = '**/libopencore-amrnb.a', '**/libopencore-amrwb.a'
  s.xcconfig = { "LIBRARY_SEARCH_PATHS" => "\"$(PODS_ROOT)/**\"" }

end