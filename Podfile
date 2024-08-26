# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'  # Updated to iOS 10 for better compatibility

target 'mymedicos' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  pod 'leveldb-library'         # Internal
  pod 'lottie-ios'         # Lottie Animations

  # Pods for mymedicos

  pod 'Firebase/Analytics'        # Firebase Core + Analytics
  pod 'Firebase/Auth'             # Firebase Authentication
  pod 'Firebase/Firestore'        # Firebase Firestore
  pod 'Firebase/Database'         # Firebase Realtime Database
  pod 'Firebase/Storage'          # Firebase Storage
  pod 'Firebase/DynamicLinks'     # Firebase Dynamic Links
  pod 'Firebase/Messaging'        # Firebase Messaging
  pod 'MarqueeLabel'
  pod 'Kingfisher'

  target 'mymedicosTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'mymedicosUITests' do
    # Pods for testing
  end
  
  

end

post_install do |installer|
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
            end
        end
    end
end
