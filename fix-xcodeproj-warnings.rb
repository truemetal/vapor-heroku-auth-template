#!/usr/bin/env ruby

require 'xcodeproj'

project_path = ARGV[0] || Dir.glob("./*.xcodeproj")[0]

project = Xcodeproj::Project.open(project_path)
project.targets.each do |target|
  # suppress warnings
  if [
    "Configs",
    "Console",
    "CSQLite",
    "FluentTester",
    "FrameAddress",
    "Meta",
    "MySQL",
    "MySQLDriver",
    "MySQLProvider",
    "PostgreSQL",
    "PostgreSQLProvider",
    "Sockets",
    "SQLite",
    "Sugar",
    "Validation",
    "Vapor"
  ].include? target.name
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_SUPPRESS_WARNINGS'] = 'YES'
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
    end
  end
  
  if target.name == "Run" || target.name == "App"
  	target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.1'
    end
  end
end
project.save()