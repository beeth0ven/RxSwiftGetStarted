platform :ios, '9.0'

target 'RxSwiftGetStarted' do
  use_frameworks!
    pod 'RxSwift',    '~> 3.0'
    pod 'RxCocoa',    '~> 3.0'
end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0.1'
            config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.10'
        end
    end
end

#   pod update --no-repo-update
#   The Podfile: http://guides.cocoapods.org/using/the-podfile.html
