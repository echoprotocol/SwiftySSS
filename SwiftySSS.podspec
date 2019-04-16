Pod::Spec.new do |spec|

  spec.name         = "SwiftySSS"
  spec.version      = "0.0.1"
  spec.summary      = "A pure Swift implementation of Shamir's Secret Sharing scheme."

  spec.description  = <<-DESC
A swift implementation of Shamir's Secret Sharing over GF(2^8).
                   DESC

  spec.homepage     = "https://github.com/pixelplex-mobile/SwiftySSS.git"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Fedorenko Nikita" => "n.fedorenko@pixelplex.io" }

  spec.ios.deployment_target = "10.0"
  spec.swift_version = "5.0"

  spec.source        = { :git => "https://github.com/pixelplex-mobile/SwiftySSS.git", :tag => "#{spec.version}" }
  spec.source_files  = "SwiftySSS/**/*.{h,m,swift}"

end