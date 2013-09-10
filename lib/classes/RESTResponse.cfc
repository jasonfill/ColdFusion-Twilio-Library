<!--- 
	The MIT License (MIT)

	Copyright (c) 2011 Jason Fill (@jasonfill)
	
	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
	associated documentation files (the "Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
	copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the 
	following conditions:
	
	The above copyright notice and this permission notice shall be included in all copies or substantial 
	portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
	NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
	OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 --->
<cfcomponent displayname="TwilioRESTResponse">
	
	<cfset variables.Instance = StructNew() />
	
	<cffunction name="init" access="public" returntype="any" output="false">	
		<cfargument name="RequestObj" type="any" />
		<cfargument name="Response" type="struct" />
				
		<cfset variables.Instance.RawResponse = Arguments.Response />
		<cfset variables.Instance.HttpStatusCode = trim(Left(Arguments.Response.StatusCode, 3)) />
		<cfset variables.Instance.HttpStatusText = trim(right(Arguments.Response.StatusCode, len(Arguments.Response.StatusCode) - 3))  />
		
		<cfif StructKeyExists(Arguments.Response.ResponseHeader, "Last-Modified")>
			<cfset variables.Instance.ContentLength = Arguments.Response.ResponseHeader["Content-Length"] />
		<cfelse>
			<cfset variables.Instance.ContentLength = ""/>
		</cfif>
		
		<cfset variables.Instance.ContentType = Arguments.Response.ResponseHeader["Content-Type"]  />
		<cfset variables.Instance.ETag = Arguments.Response.ResponseHeader.etag  />
		<cfif StructKeyExists(Arguments.Response.ResponseHeader, "Last-Modified")>
			<cfset variables.Instance.LastModified = Arguments.Response.ResponseHeader["Last-Modified"]  />
		</cfif>			
		
		<cfif Arguments.RequestObj.getResponseFormat() EQ "xml">
			<cfset variables.instance.ResponseContent = XmlParse(Arguments.Response.fileContent) />
			<cfset variables.Instance.ResponseString = Arguments.Response.fileContent  />
		<cfelseif Arguments.RequestObj.getResponseFormat() EQ "json">
			<cfset variables.instance.ResponseContent = DeserializeJSON(Arguments.Response.fileContent.toString()) />
			<cfset variables.Instance.ResponseString = Arguments.Response.fileContent.toString()  />
		<cfelse>
			<cfset variables.Instance.ResponseString = Arguments.Response.fileContent  />
			<cfset variables.Instance.ResponseContent = Arguments.Response.fileContent  />
		</cfif>

		<cfreturn this />
	</cffunction>
	
	<cffunction name="output" access="public" returntype="any" output="false" hint="Return the response as represented by the CFML engine.">
		<cfreturn variables.Instance.ResponseContent />
	</cffunction>
	
	<cffunction name="asString" access="public" returntype="string" output="false" hint="Return the response as a string.">
		<cfreturn variables.Instance.ResponseString />
	</cffunction>
	
	<cffunction name="wasSuccessful" access="public" returntype="boolean" output="false" hint="Indicate whether the request was successful or not.">
		<cfif variables.Instance.HttpStatusCode LT "400">
			<cfreturn true />		
		</cfif>
		<cfreturn false />
	</cffunction>
	
	<cffunction name="getStatusCode" access="public" returntype="string" output="false">	
		<cfreturn variables.Instance.HttpStatusCode />
	</cffunction>
	<cffunction name="getStatusText" access="public" returntype="string" output="false">	
		<cfreturn variables.Instance.HttpStatusText />
	</cffunction>
	<cffunction name="getContentLength" access="public" returntype="string" output="false">	
		<cfreturn variables.Instance.ContentLength />
	</cffunction>
	<cffunction name="getContentType" access="public" returntype="string" output="false">	
		<cfreturn variables.Instance.ContentType />
	</cffunction>
	<cffunction name="getETag" access="public" returntype="string" output="false">	
		<cfreturn variables.Instance.ETag />
	</cffunction>
	<cffunction name="getLastModified" access="public" returntype="string" output="false">	
		<cfreturn variables.Instance.LastModified />
	</cffunction>
	<cffunction name="raw" access="public" returntype="struct" output="false" hint="Returns the complete raw HTTP response.">	
		<cfreturn variables.Instance.RawResponse />
	</cffunction>

	<cffunction name="dump" access="public" returntype="struct" output="false">
		<cfreturn variables.Instance />
	</cffunction>

</cfcomponent>