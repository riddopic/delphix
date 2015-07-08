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

require 'addressable/uri'

module Delphix
  class Request
    include Delphix::Utils

    # @!attribute [r] method
    #   The HTTP method used, 'GET', 'POST', or 'DELETE'.
    #   @return [String]
    attr_reader :method
    # @!attribute [r] url
    #   The API path/URL to POST, GET, DELETE from/to.
    #   @return [String]
    attr_reader :url
    # @!attribute [r] headers
    #   The HTTP headers, symbolized and underscored.
    #   @return [Hash]
    attr_reader :headers
    # @!attribute [r] body
    #   The parsed response body where applicable (JSON responses are parsed
    #   to Objects/Associative Arrays).
    #   @return [Hash]
    attr_reader :body
    # @!attribute [r] all
    #   The raw_body un-parsed response body.
    #   @return [JSON]
    attr_reader :all

    def add_header(name, value)
      @headers[name] = value
    end

    # @param [Symnol] method
    #   A valid HTTP verb `GET`, `POST`, `PUT`, `PATCH` or `DELETE`.
    #
    # @param [String] url
    #   Endpoint (address or uri) to send request.
    #
    # @param [String, Hash, Object] body
    #   The request Body.
    #
    # @param [Proc] callback
    #    Asychronous callback method to be invoked upon result.
    #
    def initialize(method, url, headers = {}, body = nil)
      @method = method

      if method == :get
        if body.respond_to?(:keys) && body.respond_to?(:[]) && body.length > 0
          url += url.include?('?') ? '&' : '?'
          uri = Addressable::URI.new
          uri.query_values = body
          url += uri.query
        end
      else
        @body = body
      end

      if url =~ URI.regexp
        @url = url.gsub(/\s+/, '%20')
      else
        raise "Invalid URL: #{url}"
      end

      @headers = { 'Date' => utc_httpdate, 'Request-ID' => request_id }
      headers.each_pair { |key, value| @headers[key.downcase] = value }
      Delphix.last_request = { headers: @headers, method: @method, url: @url }
      begin
        Delphix.last_request[:body] = JSON.parse(@body) if body.length > 2
      rescue Exception
      end
    end
  end
end
