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
<cfcomponent displayname="RestClient">
	
	<cfset variables.instance = StructNew() />	
	<cfset variables.instance.ApiVersion = "2010-04-01" />
	<cfset variables.instance.EndPoint = "api.twilio.com" />
	<cfset variables.instance.AccoutSid = "" />
	<cfset variables.instance.AutToken = "" />
	<cfset variables.instance.DefaultResponse = "xml" />
	<cfset variables.instance.ValidResponseFormats = "xml,json,csv,html" />
	
	<cffunction name="init" access="public" output="false">	
		<cfargument name="accountSid" required="true"/>
		<cfargument name="authToken" required="true"/>
		<cfargument name="ApiVersion" required="true"/>
		<cfargument name="EndPoint" required="true"/>
		<cfargument name="DefaultResponse" default="xml" required="true"/>
		<cfset variables.instance.AccountSid = Arguments.accountSid />
		<cfset variables.instance.AuthToken = Arguments.authToken />
		<cfset variables.instance.ApiVersion = Arguments.ApiVersion />
		<cfset variables.instance.EndPoint = Arguments.EndPoint />
		<cfset variables.instance.DefaultResponse = Arguments.DefaultResponse />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="sendRequest" access="public" output="false" hint="Constructs the HTTP request and sends it off to Twilio.">	
		<cfargument name="Resource" type="string" required="true" hint="The resource that is being requested."/>
		<cfargument name="Method" type="string" required="true" default="GET" hint="The HTTP method that is being used to request the resource, valid methods include: GET, POST, PUT, DELETE."/>
		<cfargument name="Vars" type="struct" required="true" default="#StructNew()#" hint="The parameters that are to be sent with the request."/>		
		<cfset var requestObj = createObject("component", "RESTRequest").init() />
		<cfset var v = "" />
		<cfset var fieldType = "formfield" />
		<cfset var response = "" />
		<cfset var paramKey = "" />
		<!--- Make sure the method is valid... --->
		<cfif NOT ListFindNoCase("GET,POST,PUT,DELETE", Arguments.Method)>
			<cfthrow type="TwilioRESTMethodException" detail="#Arguments.Method# is not a valid HTTP method for any Twilio REST resources.  Valid methods include: GET, POST, PUT, DELETE." />
		</cfif> 
		<!--- Build the URL...  --->
		<cfset buildURL(Resource=Arguments.Resource, requestObj=requestObj) />
		<!--- If the method is get, we need to pass the params as URL variables... --->
		<cfif Arguments.Method EQ "GET">
			<cfset fieldType = "url"/>
 		</cfif>
 		
 		<!--- Set the parameters in the requestObject... --->
 		<cfset requestObj.setParameters(fieldType, arguments.Vars) />	
		<!--- Send the request off to Twilio... --->
		<cfhttp url="#requestObj.getURL()#" 
						method="#Arguments.method#" 
						result="response" 
						username="#variables.instance.AccountSid#" 
						password="#variables.instance.AuthToken#">
			<cfloop collection="#Arguments.vars#" item="v">
				<cfhttpparam name="#verifyParameterKey(v, requestObj)#" value="#Arguments.vars[v]#" type="#fieldType#"  />
			</cfloop>
		</cfhttp>		
		<!--- Process the response... --->
		<cfset requestObj.handleResponse(response) />
		<!--- Return the request object... --->
		<cfreturn requestObj />
	</cffunction>
	
	<cffunction name="verifyParameterKey" access="private" returntype="string" output="false" hint="Verifies the parameter key is a valid key for any Twilio REST resource and ensures that the key is in the proper case.">	
		<cfargument name="parameter" type="string" required="true" hint="The parameter to check."/>
		<cfargument name="requestObj" type="any" required="true" hint="An instance of the RESTRequest object which will be used to get the valid parameters."/>
		<cfset var fixedParamKey = "" />
		<!--- Make sure the parameter exists in the list of valid parameters... --->
		<cfset var keyIndex = ListFindNoCase(requestObj.getValidParameterList(), Arguments.Parameter, ",") />
		<cfif val(keyIndex) GT 0>
			<!--- If the parameter was located, return the value from the list, this will ensure that the value was not converted to upper case by the CFML engine... --->
			<cfreturn ListGetAt(requestObj.getValidParameterList(), keyIndex, ",") />
		<cfelse>
			<cfthrow type="TwilioRESTParameterException" detail="#Arguments.Parameter# is not a valid parameter for any Twilio REST resources.  Please check the parameter and the Twilio docs (<a href='http://www.twilio.com/docs/api/rest' target='_blank'>http://www.twilio.com/docs/api/rest</a>) to check the valid parameters." />
		</cfif>		
	</cffunction>
	
	<cffunction name="buildUrl" access="private" returntype="struct" output="false" hint="Builds the full URL for the resource being accessed.">	
		<cfargument name="resource" default="" required="true"/>
		<cfargument name="requestObj" default="" required="true"/>
		<cfset var local = StructNew() />
		<cfset local.url = Arguments.resource />
		<cfset local.apiVersion = "" />
		<cfset local.responseFormatIncluded = 0 />
		<cfset local.responseFormat = variables.instance.DefaultResponse />
		<cfset local.slashStart = "1" />
		<!--- Check to see if the API version is specified in the resource... --->
		<cfset local.apiLoc = ReFind("(/?)([0-9]{4}\-[0-9]{2}-[0-9]{2})?", Arguments.Resource, 1, 1) />	
		
		<cfif local.apiLoc.LEN[3] GT 0 AND  local.apiLoc.POS[3] GT 0>
			<cfset local.apiVersion = mid(Arguments.Resource, apiLoc.POS[3], apiLoc.LEN[3]) />
		</cfif>

		<cfif left(Arguments.Resource, 1) NEQ "/">
			<cfset local.slashStart = 0 />
		</cfif>
		
		<cfif NOT local.slashStart>
			<cfset local.url = "/" & Arguments.Resource />
		</cfif>
		
		<cfif NOT len(trim(local.apiVersion))>
			<cfset local.url = "/" & variables.instance.ApiVersion & local.url />
			<cfset local.ApiVersion = variables.instance.ApiVersion/>
		</cfif>
		<!--- Replace {AccountSid} if required... --->
		<cfif FindNoCase("{AccountSid}", local.url)>
			<cfset local.url = ReplaceNoCase(local.url, "{AccountSid}", variables.instance.AccountSid) />
		</cfif>
		
		<!--- Now ensure the format is being specified... --->
		<cfloop list="#variables.instance.ValidResponseFormats#" index="f">
			<cfif FindNoCase("." & f, right(local.url, len(f) + 1))>
				<cfset local.responseFormat = f />
				<cfset local.responseFormatIncluded = 1 />
				<cfbreak />
			</cfif>
		</cfloop>
		<!--- If there is no response format included, go ahead and include it... --->	
		<cfif NOT local.responseFormatIncluded>
			<cfset local.url = local.url & "." & local.responseFormat />
		</cfif>
		
		<cfset local.url = "https://" & variables.instance.EndPoint & local.url />
		
		<cfset Arguments.requestObj.setApiVersion(local.ApiVersion) />
		<cfset Arguments.requestObj.setUrl(local.url) />
		<cfset Arguments.requestObj.setResponseFormat(local.responseFormat) />
		
		<cfreturn Arguments.requestObj />
	</cffunction>

</cfcomponent>