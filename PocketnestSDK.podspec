Pod::Spec.new do |s|
  s.name             = "PocketnestSDK"
  s.version          = "1.0.0"
  s.summary          = "Pocketnest iOS SDK"
  s.description      = <<-DESC
    iOS SDK for Pocketnest.
  DESC
  s.homepage         = "https://github.com/pocketnest/PocketnestSDK-iOS"
  s.license          = { :type => "MIT", :file => "LICENSE" }   # or your license
  s.author           = { "Pocketnest" => "support@pocketnest.com" }
  s.source           = { :git => "https://github.com/pocketnest/PocketnestSDK-iOS.git",
                         :tag => s.version.to_s }

  s.platform         = :ios, "14.0"
  s.swift_versions   = ["5.9", "5.10"]
  s.module_name      = "PocketnestSDK"
  s.static_framework = true   # good default for SDKs to avoid ODR issues

  # Swift / ObjC sources
  s.source_files     = "Sources/**/*.{swift,h,m}"

  # If you ship assets, put them in Sources/PocketnestSDK/Resources
  # and uncomment one of the resource options:
  # s.resource_bundles = {
  #   "PocketnestSDKResources" => ["Sources/PocketnestSDK/Resources/**/*"]
  # }
  # or
  # s.resources = ["Sources/PocketnestSDK/Resources/**/*"]

  # If you rely on system frameworks:
  s.frameworks       = "WebKit", "AuthenticationServices"

  # Example of 3rd-party deps (uncomment/adjust as needed):
  # s.dependency "Branch", "~> 3.7"
  # s.dependency "BrazeKit", "~> 9.0"
  # s.dependency "Plaid", "~> 5.0"
end