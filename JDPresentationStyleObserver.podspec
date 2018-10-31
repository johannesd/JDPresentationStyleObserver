Pod::Spec.new do |s|
  s.name         = "JDPresentationStyleObserver"
  s.version      = "0.0.2"
  s.summary      = "JDPresentationStyleObserver"
  s.description  = <<-DESC
    JDPresentationStyleObserver
                   DESC
  s.homepage     = "https://github.com/johannesd/JDPresentationStyleObserver.git"
  s.license      = { 
    :type => 'Custom permissive license',
    :text => <<-LICENSE
          Free for commercial use and redistribution. No warranty.

        	Johannes Dörr
        	mail@johannesdoerr.de
    LICENSE
  }
  s.author       = { "Johannes Doerr" => "mail@johannesdoerr.de" }
  s.source       = { :git => "https://github.com/johannesd/JDPresentationStyleObserver.git" }
  s.platform     = :ios, '8.0'
  s.source_files  = '*.{h,m}'

  s.exclude_files = 'Classes/Exclude'
  s.requires_arc = true

end
