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

require 'securerandom'

module Delphix
  module Utils
    # Return the date and time in "HTTP-date" format as defined by RFC 7231.
    #
    # @return [Date,Time] in "HTTP-date" format
    def utc_httpdate
      Time.now.utc.httpdate
    end

    # Generates a uniq UUID, this is then used to identify this session.
    #
    # @return [String]
    #   Memoize a uniq UUID used to identify this session.
    #
    def request_id
      @uuid ||= SecureRandom.uuid
    end
  end
end

class Hash
  # Returns a new Hash, recursively downcasing and converting all
  # keys to symbols.
  #
  # @return [Hash]
  #
  def recursively_normalize_keys
    recursively_transform_keys { |key| key.downcase.to_sym rescue key }
  end

  private #   P R O P R I E T À   P R I V A T A   divieto di accesso

  # support methods for recursively transforming nested hashes and arrays
  #
  def _recursively_transform_keys_in_object(object, &block)
    case object
    when Hash
      object.each_with_object({}) do |(key, val), result|
        result[yield(key)] = _recursively_transform_keys_in_object(val, &block)
      end
    when Array
      object.map { |e| _recursively_transform_keys_in_object(e, &block) }
    else
      object
    end
  end
end
