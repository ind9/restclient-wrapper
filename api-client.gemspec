Gem::Specification.new do |s|
  s.name        = 'api-client'
  s.version     = '0.1'
  s.date        = '2014-08-12'
  s.summary     = "Rest API wrapper written in ruby. Can be used to communicate to all Indix internal APIs"
  s.description = "Rest API wrapper written in ruby. Can be used to communicate to all Indix internal APIs"
  s.authors     = ["Azhagu Selvan"]
  s.email       = 'azhaguselvan@indix.com'
  s.files       = ["lib/api_client.rb", "lib/api_response_base.rb", "lib/exceptions.rb"]
  s.homepage    =
    'http://indix.com'
  s.license       = 'MIT'
	s.add_runtime_dependency 'rest_client',  '~>1.0' 
	s.add_runtime_dependency 'activesupport', '~>4.0'
end
