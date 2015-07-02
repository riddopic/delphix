
# Basic Delphix Cookbook

Set the values for host, username and password:

```
node[:delphix][:host] = 'delphix.example.com'
node[:delphix][:username] = 'admin'
node[:delphix][:password] = 'd3lph1X'
```

Then in a recipe use:

First establish a session with the Delphix appliance using the specified API version:

     Delphix.api_version = {
       type: 'APIVersion',
       major: node[:delphix][:api_version]
     }

Specify the Delphix server name.

     Delphix.server     = node[:delphix][:server]

Specify the Delphix username.

     Delphix.api_user   = node[:delphix][:username]

Specify the Delphix password.

     Delphix.api_passwd = node[:delphix][:password]

Now we have an established session, go crazy.

## The Delphix object support the following HTTP methods are supported:

### GET

Retrieve data from the server where complex input is not needed. All GET requests are guaranteed to be read-only, but not all read-only requests are required to use GET. Simple input (strings, number, boolean values) can be passed as query parameters.

     Delphix.get session

### POST

Issue a read/write operation, or make a read-only call that requires complex input. The optional body of the call is expressed as JSON.

     Delphix.post provision, { "JSON": "DATA" }

### DELETE

Delete an object on the system. For languages that don't provide a native wrapper for DELETE, or for delete operations with optional input, all delete operations can also be invoked as POST to the same URL with /delete appended to it.

Each method returns a hash that responds to `#code`, `#headers`, `#body` and `#raw_body` obtained from parsing the JSON object in the response body.

	@param [String<URL>] url
	  The url of where to send the request.
	
	@param [Hash] parameters
	  Data in the form of key/value.
	
	@param [Proc] block
	  Block to execute when the request returns.
	
	@return [Fixnum, #code]
	  The response code from Delphix engine.
	
	@return [Hash, #headers]
	  The headers, beautified with symbols and underscores.
	
	@return [Hash, #body]
	  The parsed response body where applicable (JSON  responses are parsed to
	  Objects/Associative Arrays)
	
	@return [Hash, #raw_body]
	  The raw_body, un-parsed response body.

For some debuging help you can return the last message body:

     ap Delphix.session.body

Return the last request sent:

     ap Delphix.last_request

Return the last response from the Delphix:

     ap Delphix.last_response

To get the entire API schema you can use connect to the server on the
`/api/json/delphix.json` URL. The JSON response can them be parsed and
imported so that it can be used to generate the providers.

     Delphix.get "http://#{Delphix.server}/api/json/delphix.json"```

## License and Authors

```
Author::   Stefano Harding <riddopic@gmail.com>
Copyright: 2014-2015, Stefano Harding

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
