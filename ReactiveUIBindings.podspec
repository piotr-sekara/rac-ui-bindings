Pod::Spec.new do |s|
  s.name         = "ReactiveUIBindings"
  s.version      = "0.1"
  s.summary      = "Reactive Cocoa UI bindings in RxSwift style"
  s.homepage     = "https://github.com/codewise/ReactiveCocoaUIBindings"
  s.license      = { :type => "Apache 2.0", :file => "LICENSE" }
  s.author       = { "Paweł Sękara" => "pawel.sekara@gmail.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/codewise/ReactiveCocoaUIBindings.git", :tag => "0.1" }

  s.source_files  = "ReactiveCollection"
  s.requires_arc = true
end