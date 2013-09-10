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
<cfcomponent displayname="TwilioFactory">
	
	<cfset variables.instance = StructNew() />	
	<cfset variables.instance.AccoutSid = "" />
	<cfset variables.instance.AuthToken = "" />
	<cfset variables.instance.ApiVersion = "2010-04-01" />
	<cfset variables.instance.EndPoint = "api.twilio.com" />
	<cfset variables.instance.DefaultReturnFormat = "xml" />
	
	<cffunction name="init" access="public" output="false">	
		<cfargument name="accountSid" required="true" hint="The AccountSid provided by Twilio."/>
		<cfargument name="authToken" required="true" hint="The AuthToken provided by Twilio."/>
		<cfargument name="ApiVersion" required="false" default="#variables.instance.ApiVersion#" hint="The version of the Twilio API to be used."/>
		<cfargument name="EndPoint" required="false" default="#variables.instance.EndPoint#" hint="The Twilio API endpoint." />
		<cfargument name="DefaultReturnFormat" required="false" type="string" default="#variables.instance.DefaultReturnFormat#" hint="The default return format that should be used.  This can be overridden in for REST request as well." />
		<cfset variables.instance.AccountSid = Arguments.accountSid />
		<cfset variables.instance.AuthToken = Arguments.authToken />
		<cfset variables.instance.ApiVersion = Arguments.ApiVersion />
		<cfset variables.instance.EndPoint = Arguments.EndPoint />
		<cfset variables.instance.DefaultReturnFormat = Arguments.DefaultReturnFormat />
		<cfset variables.instance.RESTClient = createObject("component", "classes.RESTClient").init(variables.instance.AccountSid, variables.instance.AuthToken, variables.instance.ApiVersion, variables.instance.EndPoint) />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="newResponse" access="public" output="false" hint="Creates a new TwiML response object.">
		<cfreturn createObject("component", "classes.TwiML").init(variables.instance.AccountSid, variables.instance.AuthToken, variables.instance.ApiVersion, variables.instance.EndPoint) />			
	</cffunction>
	
	<cffunction name="newRequest" access="public" output="false" hint="Creates a new REST request object.">
		<cfargument name="Resource" type="string" required="true" hint="The resource that is to be consumed." />
		<cfargument name="Method" type="string" required="true" default="GET" hint="The HTTP method to be used."/>
		<cfargument name="Vars" type="struct" required="true" default="#StructNew()#" hint="Any variables that are to be sent with the request."/>
		<cfreturn variables.instance.RESTClient.sendRequest(argumentCollection=arguments) />			
	</cffunction>
	
	<cffunction name="getUtils" access="public" output="false" hint="Creates a new Twilio utility object.">
		<cfreturn createObject("component", "classes.Utils").init(variables.instance.AccountSid, variables.instance.AuthToken) />			
	</cffunction>
	
	<cffunction name="getCapability" access="public" output="false" hint="Creates a new Twilio capability object.">
		<cfreturn createObject("component", "classes.Capability").init(variables.instance.AccountSid, variables.instance.AuthToken) />			
	</cffunction>
	
	
</cfcomponent>