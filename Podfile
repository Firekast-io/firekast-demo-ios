# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

# Pods for Firekast Demo
def firekast
  pod 'Firekast', :podspec => 'http://firekast.io/sdk/ios/v1.4.0/Firekast.podspec'
  pod 'VideoCore', :git => 'https://github.com/Firekast-io/VideoCore.git', :tag => 'fk-1.4.0'
end

def google
  pod 'GoogleSignIn', '4.3.0'
end

target 'Firekast Demo' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  firekast
  google

end

target 'Firekast Demo Objective-C' do
  use_frameworks!
  
  firekast
  google
  
end
