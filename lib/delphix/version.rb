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

# The version number of the Delphix Gem
#
# @return [String]
#
# @api public
module Delphix
  # Contains information about this gem's version
  module Version
    MAJOR = 0
    MINOR = 4
    PATCH = 2

    # Returns a version string by joining MAJOR, MINOR, and PATCH with '.'
    #
    # @example
    #   Version.string # => '1.0.1'
    #
    def self.string
      [MAJOR, MINOR, PATCH].join('.')
    end
  end

  VERSION = Delphix::Version.string
end
