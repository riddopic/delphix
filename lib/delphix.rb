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

require 'rest-client'
require 'hashie'
require_relative 'delphix/utils'
require_relative 'delphix/client'
require_relative 'delphix/request'
require_relative 'delphix/response'
require_relative 'delphix/version'

# A library for supporting connections to the Delphix API. The module Delphix
# is based on the singleton pattern, which restricts instantiation of a class
# to only one instance that is globally available.
#
# @example
#   To establish a session with the Delphix appliance and get a cookies for
#   your effort you issue the following sequence:
#
#   * Configure the Delphix client to use the specified version of the API, in
#     hash format as `{ major: 1, micro: 0, minor: 0 }`, for example:
#       Delphix.api_version = {
#         type: 'APIVersion',
#         version: { major: 1, micro: 0, minor: 0 }
#       }
#   * Specify the Delphix server to connect to.
#       Delphix.server = 'delphix.example.com'
#   * Specify the Delphix username to connect with.
#       Delphix.api_user = 'delphix'
#   * Specify the Delphix password to use.
#       Delphix.api_passwd = 'delphix'
#   * Now you have an established session, go crazy.
#
module Delphix
  include Utils

  API_ENDPOINT = '/resources/json/delphix'
  HTTP_HEADERS = {
    'Content-Type' =>  'application/json; charset=UTF-8',
    'User-Agent'   =>  'Delphix-Ruby-Client/' + Delphix::VERSION
  }

  # Default timeout value in seconds.
  @@timeout = 10

  # Default headers
  @@default_headers = {}

  class << self
    # @!attribute [rw] last_request
    #   @return [Hash] retruns the last request
    attr_accessor :last_request
    # @!attribute [rw] last_response
    #   @return [Hash] retruns the last response
    attr_accessor :last_response
    # @!attribute [rw] session
    #   @return [Hash] retruns current session state
    #   @return [#code] the response code from Delphix engine
    #   @return [#headers] beautified with symbols and underscores
    #   @return [#body] parsed response body
    #   @return [#raw_body] un-parsed response body
    attr_accessor :session
    # @!attribute [rw] server
    #   @return [String] Delphix server address
    attr_accessor :server
    # @!attribute [rw] api_user
    #   @return [String] username to authenticate with
    attr_accessor :api_user
    # @!attribute [rw] api_passwd
    #   @return [String] password for authentication
    attr_accessor :api_passwd
  end

  # Defines custom setter that takes a string, splits on the `.` and setting
  # the major, minor and micro versions.
  #
  # @param [String] name
  #   Name of the setter
  #
  # @param [String] version
  #   The version number, i.e. '1.2.3'
  #
  # @return [undefined]
  #
  def self.version_accessor(name, version = nil)
    define_singleton_method("#{name}=") do |version|
      instance_variable_set("@#{name}",
        [:major, :minor, :micro].zip(version.split('.')).inject({}) {
          |r, i| r[i[0]] = i[1]; r
        }.merge(type: 'APIVersion')
      )
    end
  end

  # @!attribute [rw] api_version
  #   @return [Hash] containing the major, minor and micro version numbers.
  self.version_accessor :api_version

  # Returns the API endpoint for a given resource namespace by combining the
  # server address with the appropriate HTTP headers.
  #
  # @param resource [Resource] namespace
  #
  # @return [URL] return the URL for the API endpoint
  #
  # @api public
  def self.api_url(resource = nil)
    'http://' + @server + resource
  end

  # Initiate a session with the Delphix appliance, get our cookies for the
  # duration of this exchange.
  #
  # @return [undefined]
  #
  def self.session
    Delphix.default_header(:cookies, cookies)
    @session ||= login(@api_user, @api_passwd)
  end

  # Establish a session with the Delphix engine and return an identifier
  # through browser cookies. This session will be reused in subsequent calls,
  # the same session credentials and state are preserved without requiring a
  # re-authentication call. Sessions do not persisit between incovations.
  #
  # @return [Hash] cookies
  #   containing the new session cookies
  #
  # @api public
  def self.cookies
    @resp ||= Delphix.post session_url,
      type: 'APISession', version: @api_version
    @resp.cookies
  end

  # Authenticates the session so that API calls can be made. Only supports basic
  # password authentication.
  #
  # @param [String] user
  #   user name to authenticate with
  # @param [String] passwd
  #   password to authenticate with
  #
  # @return [Fixnum, #code]
  #   the response code from Delphix engine
  # @return [Hash, #headers]
  #   headers, beautified with symbols and underscores
  # @return [Hash, #body] body
  #   parsed response body where applicable (JSON responses are parsed to
  #   Objects/Associative Arrays)
  # @return [Hash, #raw_body] raw_body
  #   un-parsed response body
  #
  # @api public
  def self.login(user = @api_user, passwd = @api_passwd)
    Delphix.post login_url,
      type: 'LoginRequest', username: user, password: passwd
  end

  # @!method alert
  #   A helper method to return the URL for the resource by using the
  #   resource_url shorthand.
  #   @return [String] The API path to alert.
  #
  # @!method container
  #   A helper method to return the URL for the resource by using the
  #   resource_url shorthand.
  #   @return [String] The API path to container.
  #
  # @!method database
  #   A helper method to return the URL for the resource by using the
  #   resource_url shorthand.
  #   @return [String] The API path to database.
  #
  # @!method environment
  #   A helper method to return the URL for the resource by using the
  #   resource_url shorthand.
  #   @return [String] The API path to environment.
  #
  # @!method group
  #   A helper method to return the URL for the resource by using the
  #   resource_url shorthand.
  #   @return [String] The API path to group.
  #
  # @!method host
  #   A helper method to return the URL for the resource by using the
  #   resource_url shorthand.
  #   @return [String] The API path to host.
  #
  # @!method job
  #   A helper method to return the URL for the resource by using the
  #   resource_url shorthand.
  #   @return [String] The API path to job.
  #
  # @!method login
  #   A helper method to return the URL for the resource by using the
  #   resource_url shorthand.
  #   @return [String] The API path to login.
  #
  # @!method policy
  #   A helper method to return the URL for the resource by using the
  #   resource_url shorthand.
  #   @return [String] The API path to policy.
  #
  # @!method repository
  #   A helper method to return the URL for the resource by using the
  #   resource_url shorthand.
  #   @return [String] The API path to repository.
  #
  # @!method session
  #   A helper method to return the URL for the resource by using the
  #   resource_url shorthand.
  #   @return [String] The API path to session.
  #
  # @!method snapshot
  #   A helper method to return the URL for the resource by using the
  #   resource_url shorthand.
  #   @return [String] The API path to snapshot.
  #
  # @!method source
  #   A helper method to return the URL for the resource by using the
  #   resource_url shorthand.
  #   @return [String] The API path to source.
  #
  # @!method sourceconfig
  #   A helper method to return the URL for the resource by using the
  #   resource_url shorthand.
  #   @return [String] The API path to sourceconfig.
  #
  # @!method timeflow
  #   A helper method to return the URL for the resource by using the
  #   resource_url shorthand.
  #   @return [String] The API path to timeflow.
  #
  # @!method user
  #   A helper method to return the URL for the resource by using the
  #   resource_url shorthand.
  #   @return [String] The API path to user.
  #
  [ :alert, :container, :database, :environment, :group, :host, :job,
    :login, :policy, :repository, :session, :snapshot, :source,
    :sourceconfig, :timeflow, :user
  ].each do |name|
    define_singleton_method(name.to_s + '_url') do
      api_url('/resources/json/delphix/' + name.to_s)
    end
  end

  # @return [String] object inspection
  # @!visibility private
  def inspect
    instance_variables.inject([
      "\n#<#{self.class}:0x#{object_id.to_s(16)}>",
      "\tInstance variables:"
    ]) do |result, item|
      result << "\t\t#{item} = #{instance_variable_get(item)}"
      result
    end.join("\n")
  end

  # @return [String] string of instance
  # @!visibility private
  def to_s
    "<#{self.class}:0x#{object_id.to_s(16)} session=#{@session}>"
  end
end
