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
  class Client
    include Delphix::Utils

    # @param [Symnol] method
    #   A valid HTTP verb `:get`, `:post`, or `:delete`.
    #
    # @param [String] url
    #   The address or uri to send request.
    #
    # @param [String, Hash, Object] body
    #   The request Body.
    #
    # @param [Proc] callback
    #    Asychronous callback method to be invoked upon result.
    #
    def self.request(method, url, headers, body, timeout, &callback)
      request = Delphix::Request.new(method, url, headers, body)

      if callback
        Thread.new do
          callback.call(internal_request(request, timeout))
        end
      else
        internal_request(request, timeout)
      end
    end

    def self.internal_request(request, timeout)
      HTTP_HEADERS.each { |key, value| request.add_header(key, value) }
      response = nil

      begin
        case request.method
        when :get
          response = RestClient::Request.execute(
            method: :get,
            url:     request.url,
            headers: request.headers,
            timeout: timeout
          )
        when :post
          response = RestClient::Request.execute(
            method: :post,
            url:     request.url,
            payload: request.body.to_json,
            headers: request.headers,
            timeout: timeout
          )
        when :delete
          response = RestClient::Request.execute(
            method: :delete,
            url:     request.url,
            payload: request.body.to_json,
            headers: request.headers,
            timeout: timeout
          )
        end
      rescue RestClient::RequestTimeout
        raise 'Request Timeout'
      rescue RestClient::Exception => e
        response = e.response
      end

      Delphix::Response.new(response)
    end
  end

  # @param [String, Symbol] name
  #   A string or symbol used to identify the key portion of the HTTP headers.
  #
  # @param [String, Symbol, Array] value
  #   A string, symbol or array containing the values of the HTTP header.
  #
  # @return [Hash]
  #   The result of the key/value pair.
  #
  def self.default_header(name, value)
    @@default_headers[name] = value
  end

  # @return [Hash]
  #   The HTTP headers sent with a POST/GET/DELETE.
  #
  def self.clear_default_headers
    @@default_headers = {}
  end

  # @param [Integer] seconds
  #   Set the number of seconds to wait for an HTTP timeout.
  #
  # @return [undefined]
  #
  def self.timeout(seconds)
    @@timeout = seconds
  end

  # @!method get
  #   Retrieve data from the server where complex input is not needed. All GET
  #   requests are guaranteed to be read-only, but not all read-only requests
  #   are required to use GET. Simple input (strings, number, boolean values)
  #   can be passed as query parameters.
  #
  #   @param [String] url, (address or uri) to send request.
  #   @param [String, Hash, Object] body, the request body.
  #   @param [Proc] callback, asychronous callback method, invoked upon result.
  #
  #   @return [Fixnum, #code] the response code from Delphix engine.
  #   @return [Hash, #headers] The headers with keys as symbols.
  #   @return [Hash, #body] body parsed response body where applicable.
  #   @return [Hash, #raw_body] raw_body un-parsed response body.
  #
  # @!method post
  #   Issue a read/write operation, or make a read-only call that requires
  #   complex input. The optional body of the call is expressed as JSON.
  #
  #   @param [String] url, (address or uri) to send request.
  #   @param [String, Hash, Object] body, the request body.
  #   @param [Proc] callback, asychronous callback method, invoked upon result.
  #
  #   @return [Fixnum, #code] the response code from Delphix engine.
  #   @return [Hash, #headers] The headers with keys as symbols.
  #   @return [Hash, #body] body parsed response body where applicable.
  #   @return [Hash, #raw_body] raw_body un-parsed response body.
  #
  # @!method delete
  #   Delete an object on the system. For languages that don't provide a native
  #   wrapper for DELETE, or for delete operations with optional input, all
  #   delete operations can also be invoked as POST to the same URL with
  #   /delete appended to it.
  #
  #   @param [String] url, (address or uri) to send request.
  #   @param [String, Hash, Object] body, the request body.
  #   @param [Proc] callback, asychronous callback method, invoked upon result.
  #
  #   @return [Fixnum, #code] the response code from Delphix engine.
  #   @return [Hash, #headers] The headers with keys as symbols.
  #   @return [Hash, #body] body parsed response body where applicable.
  #   @return [Hash, #raw_body] raw_body un-parsed response body.
  #
  [:get, :post, :delete].each do |method|
    define_singleton_method(method) do |url, parameters = {}, &callback|
      Client.request(method.to_sym, url, @@default_headers,
        parameters.to_json, @@timeout, &callback)
    end
  end
end
