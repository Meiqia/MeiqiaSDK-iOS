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

  s.resource_bundles = {
    'MQChatViewAsset' => ['Meiqia-SDK-files/MQChatViewController/Assets/MQChatViewAsset.bundle']
  }
  # s.source_files = 'Meiqia-SDK-files/MeiqiaSDKViewInterface/*.{h,m}', 'Meiqia-SDK-files/MQChatViewController/**/*.{h,m,mm,cpp}'
  # s.vendored_frameworks = 'Meiqia-SDK-files/MeiQiaSDK.framework'
  s.subspec 'MeiqiaSDK' do |ss|
    ss.frameworks =  'AVFoundation', 'CoreTelephony', 'SystemConfiguration', 'MobileCoreServices'
    ss.libraries  =  'sqlite3', 'icucore'
    ss.vendored_frameworks = 'Meiqia-SDK-files/MeiQiaSDK.framework'
  end
  s.subspec 'MQChatViewController' do |ss|
    ss.dependency 'Meiqia/MeiqiaSDK'
    ss.source_files = 'Meiqia-SDK-files/MeiqiaSDKViewInterface/*.{h,m}', 'Meiqia-SDK-files/MQChatViewController/**/*.{h,m,mm,cpp}'
    ss.vendored_libraries = 'Meiqia-SDK-files/MQChatViewController/Vendors/MLAudioRecorder/amr_en_de/lib/libopencore-amrnb.a', 'Meiqia-SDK-files/MQChatViewController/Vendors/MLAudioRecorder/amr_en_de/lib/libopencore-amrwb.a'
    ss.preserve_path = '**/libopencore-amrnb.a', '**/libopencore-amrwb.a'
    ss.xcconfig = { "LIBRARY_SEARCH_PATHS" => "\"$(PODS_ROOT)/**\"" }
  end
  
  

end