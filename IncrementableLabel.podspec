Pod::Spec.new do |s|

# ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

s.name            	= "IncrementableLabel"
s.module_name      	= "IncrementableLabel"
s.version          	= "1.1.0"
s.summary          	= "IncrementableLabel is the easiest way to have incrementable numbers in an UILabel!"
s.description      	= "IncrementableLabel is the easiest way to have incrementable numbers in an UILabel! Available on iOS and tVOS"
s.homepage         	= "https://github.com/recisio/IncrementableLabel"
s.license      		= { :type => "MIT", :file => "LICENSE" }
s.author           	= { "Recisio" => "tom.baranes@gmail.com" }
s.source           	= { :git => "https://github.com/recisio/IncrementableLabel.git", :tag => "#{s.version}" }

# ―――  Spec tech  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

s.ios.deployment_target		= '8.0'
s.tvos.deployment_target 	= '9.0'

s.requires_arc 	   			= true
s.source_files				= 'Sources/*.swift'

end
