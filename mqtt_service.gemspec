Gem::Specification.new do |s|
  s.name = 'mqtt_service'
  s.authors = [
    'nickthecook@tinytown.ca'
  ]
  s.version = '0.5.7'
  s.date = '2018-11-18'
  s.summary = 'mqtt_service provides a framework for MQTT-based services'
  s.files = [
    'Gemfile',
    'README.md',
    'lib/logging.rb',
    'lib/mqtt_service.rb',
    'lib/app.rb',
    'bin/mqtt_service',
    'etc/config.yml'
  ]
  s.add_runtime_dependency 'colorize', '~> 0.8', '>= 0.8.1'
  s.add_runtime_dependency 'mqtt', '~> 0.5', '>= 0.5.0'
  s.add_runtime_dependency 'recursive-open-struct', '~> 1.1', '>= 1.1.1'
end
