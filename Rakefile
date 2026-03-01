# frozen_string_literal: true

require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb"
end

require "yard"

YARD::Rake::YardocTask.new("yard:doc")

task default: :spec
