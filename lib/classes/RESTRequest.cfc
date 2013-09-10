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
<cfcomponent displayname="TwilioRESTRequest">
	
	<cfset variables.Instance = StructNew() />
	<cfset variables.Instance.ApiVersion = "" />
	<cfset variables.Instance.ResponseFormat = "" />
	<cfset variables.Instance.Request.Parameters = StructNew() />
	<cfset variables.Instance.Request.Url = "" />
	
	<cffunction name="init" access="public" output="false">	
		<cfreturn this />
	</cffunction>
	
	<cffunction name="handleResponse" access="package" returntype="void" output="false" hint="Handles the response that is returned from Twilio.">	
		<cfargument name="response" type="struct" />		
		<cfset variables.Instance.Response = createObject("component", "RESTResponse").init(this, Arguments.Response) />
	</cffunction>
	
	<cffunction name="getResponse" access="public" returntype="any" output="false" hint="Returns the response object.">
		<cfreturn variables.Instance.Response />		
	</cffunction>
		
	<cffunction name="setApiVersion" access="public" returntype="void" output="false">	
		<cfargument name="ApiVersion" type="string" /> 
		<cfset variables.Instance.APIVersion = Arguments.ApiVersion />
	</cffunction>
	<cffunction name="getApiVersion" access="public" returntype="string" output="false">	
		<cfreturn variables.Instance.ApiVersion />
	</cffunction>
	
	<cffunction name="setResponseFormat" access="public" returntype="void" output="false">	
		<cfargument name="ResponseFormat" type="string" /> 
		<cfset variables.Instance.ResponseFormat = Arguments.ResponseFormat />
	</cffunction>
	<cffunction name="getResponseFormat" access="public" returntype="string" output="false">	
		<cfreturn variables.Instance.ResponseFormat />
	</cffunction>
	
	<cffunction name="setUrl" access="public" returntype="void" output="false">	
		<cfargument name="Url" type="string" /> 
		<cfset variables.Instance.Request.Url = Arguments.Url />
	</cffunction>
	<cffunction name="getUrl" access="public" returntype="string" output="false">	
		<cfreturn variables.Instance.Request.Url />
	</cffunction>
	
	<cffunction name="setParameters" access="public" returntype="void" output="false">	
		<cfargument name="Type" type="string" />
		<cfargument name="Values" type="struct" /> 
		<cfset variables.Instance.Request.Parameters.type = Arguments.Type />
		<cfset variables.Instance.Request.Parameters.values = Arguments.values />
	</cffunction>
	<cffunction name="getParameters" access="public" returntype="struct" output="false">	
		<cfreturn variables.Instance.Request.Parameters />
	</cffunction>
	
	<cffunction name="getValidParameterList" access="public" returntype="string" output="false" hint="Returns a list of all the valid parameters for all the REST resources.">	
		<!--- Create a list of all the valid request params for all the resources.  This list
					will be used to make sure the proper case is sent in the REST request as well as
					making sure that no extraneous parameters exist in the request... --->
		<cfset var paramList = "AccountSid,AreaCode,AnsweredBy,ApiVersion,Body,CallDelay,CallDuration,CallSid,Contains,DateCreated,DateSent,DateUpdated,Distance,EndTime,Extension,FallbackMethod,FallbackUrl,FriendlyName,From,IfMachine,IncomingPhoneNumberSid,InLata,InRateCenter,InRegion,InPostalCode,IsoCountryCode,Log,MessageDate,Method,Muted,NearLatLong,NearNumber,Page,PageSize,PhoneNumber,SendDigits,SmsApplicationSid,SmsFallbackMethod,SmsFallbackUrl,SmsMethod,SmsUrl,StartTime,Status,StatusCallback,StatusCallbackMethod,Timeout,To,Url,ValidationCode,VoiceApplicationSid,VoiceCallerIdLookup,VoiceFallbackMethod,VoiceFallbackUrl,VoiceMethod,VoiceUrl" />
		<cfreturn paramList />
	</cffunction>
	
	<cffunction name="dump" access="public" returntype="struct" output="false">	
		<cfreturn variables.Instance />
	</cffunction>
	
</cfcomponent>