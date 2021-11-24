# coding: utf-8
#
# Be sure to run `pod lib lint MeiqiaSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Meiqia"
  s.version          = "3.7.8"
  s.summary          = "美洽官方 SDK for iOS"
  s.description      = "美洽官方的 iOS SDK"

  s.homepage         = "https://github.com/Meiqia/MeiqiaSDK-iOS"
  s.license          = 'MIT'
  s.author           = { "zhangshunxing" => "zhangshunxing@qipeng.com" }
  s.source           = { :git => "https://github.com/Meiqia/MeiqiaSDK-iOS.git", :tag => "v3.7.8" }
  s.social_media_url = "https://meiqia.com"
  s.documentation_url = "https://github.com/Meiqia/MeiqiaSDK-iOS/wiki"
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.subspec 'MeiqiaSDK' do |ss|
    ss.frameworks =  'AVFoundation', 'CoreTelephony', 'SystemConfiguration', 'MobileCoreServices'
    ss.vendored_frameworks = 'Meiqia-SDK-files/MeiQiaSDK.framework'
    ss.libraries  =  'sqlite3', 'icucore', 'stdc++'
    ss.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "${PODS_ROOT}/Meiqia/Meiqia-SDK-files"}
  end
  s.subspec 'MQChatViewController' do |ss|
    ss.dependency 'Meiqia/MeiqiaSDK'
    # avoid compile error when using 'use frameworks!',because this header is c++, but in unbrellar header don't know how to compile, there's no '.mm' file in the context.
    ss.private_header_files = 'Meiqia-SDK-files/MQChatViewController/Vendors/VoiceConvert/amrwapper/wav.h'
    ss.source_files = 'Meiqia-SDK-files/MeiqiaSDKViewInterface/*.{h,m}', 'Meiqia-SDK-files/MQChatViewController/**/*.{h,m,mm,cpp}', 'Meiqia-SDK-files/MQMessageForm/**/*.{h,m}'
    ss.vendored_libraries = 'Meiqia-SDK-files/MQChatViewController/Vendors/MLAudioRecorder/amr_en_de/lib/libopencore-amrnb.a', 'Meiqia-SDK-files/MQChatViewController/Vendors/MLAudioRecorder/amr_en_de/lib/libopencore-amrwb.a'
    #ss.preserve_path = '**/libopencore-amrnb.a', '**/libopencore-amrwb.a'
    ss.xcconfig = { "LIBRARY_SEARCH_PATHS" => "\"$(PODS_ROOT)/Meiqia/Meiqia-SDK-files\"" }
    ss.resources = 'Meiqia-SDK-files/MQChatViewController/Assets/MQChatViewAsset.bundle'
  end
  
  

end
