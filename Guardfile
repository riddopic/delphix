# encoding: UTF-8
#
# Author:    Stefano Harding <riddopic@gmail.com>
# License:   Apache License, Version 2.0
# Copyright: (C) 2014-2015 Stefano Harding
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

notification :growl

scope groups: [:doc, :lint, :unit]

group :doc do
  guard :shell do
    cmd = %w(knife cookbook doc -t _README.md.erb .)
    watch('metadata.rb') { system(*cmd) }
    watch('_README.md.erb') { system(*cmd) }
  end

  guard :yard do
    watch(%r{^attributes/(.+)\.rb$})
    watch(%r{^definitions/(.+)\.rb$})
    watch(%r{^libraries/(.+)\.rb$})
    watch(%r{^providers/(.+)\.rb$})
    watch(%r{^recipes/(.+)\.rb$})
    watch(%r{^resources/(.+)\.rb$})
  end
end

group :lint do
  guard :rubocop do
    watch(%r{.+\.rb$})
    watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
  end

  guard :foodcritic, cookbook_paths: '.', cli: [
    '--tags', '~FC001', '--epic-fail', 'any',
    '--include', 'test/support/foodcritic/*'
  ] do
    watch(%r{attributes/.+\.rb$})
    watch(%r{definitions/.+\.rb$})
    watch(%r{libraries/.+\.rb$})
    watch(%r{providers/.+\.rb$})
    watch(%r{recipes/.+\.rb$})
    watch(%r{resources/.+\.rb$})
  end
end

group :unit do
  guard :rspec, cmd: 'bundle exec rspec --color --format Fuubar' do
    watch(%r{^recipes/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^spec/.+_spec\.rb$})
    watch('spec/spec_helper.rb') { 'spec' }
  end
end

group :integration do
  begin
    require 'guard/kitchen'
    guard :kitchen do
      watch(%r{^attributes/(.+)\.rb$})
      watch(%r{^definitions/(.+)\.rb$})
      watch(%r{^files/(.+)})
      watch(%r{^libraries/(.+)})
      watch(%r{^providers/(.+)\.rb})
      watch(%r{^recipes/(.+)\.rb$})
      watch(%r{^resources/(.+)\.rb})
      watch(%r{^templates/(.+)})
      watch(%r{test/.+})
    end
  rescue LoadError
    puts '>>>>> Kitchen gem not loaded, omitting guards.' unless ENV['CI']
  end
end
