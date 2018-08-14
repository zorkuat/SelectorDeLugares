# Uncomment the next line to define a global platform for your project
platform :ios, '11.4'

target 'SelectorDeLugares' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MeOperoSeguro

  pod 'SQLite.swift', '~> 0.11.4'
  pod 'TagListView', '~> 1.3.1'
  
  post_install do |installer|
      installer.pods_project.build_configurations.each do |config|
          config.build_settings.delete('CODE_SIGNING_ALLOWED')
          config.build_settings.delete('CODE_SIGNING_REQUIRED')
      end
  end
  
  target 'SelectorDeLugaresTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SelectorDeLugaresUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
