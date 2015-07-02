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

require 'json'

module Delphix
  class WebResponse
    include Net::HTTPHeader
    include Delphix::Utils

    # @!attribute [r] code
    #   The HTTP response code from Delphix engine.
    #   @return [#code]
    attr_reader :code
    # @!attribute [r] method
    #   The raw_body un-parsed response body from the Delphix engine.
    #   @return [#raw_body]
    attr_reader :raw_body
    # @!attribute [r] method
    #   The parsed response body where applicable (JSON responses are parsed
    #   to Objects/Associative Arrays).
    #   @return [#body]
    attr_reader :body
    # @!attribute [r] method
    #   The HTTP headers, symbolized and underscored.
    #   @return [#headers]
    attr_reader :headers
    # @!attribute [r] method
    #   The current session cookie.
    #   @return [#raw_body]
    attr_reader :cookie

    def initialize(response)
      @code = response.code
      @headers = response.headers
      @raw_body = response
      @body = @raw_body
      @cookie = response.cookie

      Delphix.last_response = {
        code: response.code,
        headers: response.headers,
        body: JSON.parse(response.body),
        cookie: response.cookie,
        description: response.description
      }.recursively_normalize_keys

      begin
        @body = JSON.parse(@raw_body)
      rescue Exception
      end
    end

    def ==(other)
      @headers == other
    end

    def inspect
      @headers.inspect
    end

    def method_missing(name, *args, &block)
      if @headers.respond_to?(name)
        @headers.send(name, *args, &block)
      else
        super
      end
    end

    def respond_to?(method)
      super || @headers.respond_to?(method)
    end
  end
end
