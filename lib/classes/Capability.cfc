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
 
<cfcomponent displayname="TwilioCapability">
	
	<cfset variables.instance = StructNew() />	
	<cfset variables.instance.Scopes = "" />
	<cfset variables.instance.AccoutSid = "" />
	<cfset variables.instance.AuthToken = "" />
	
	<!--- // Incoming Parameter holding until generate token time --->
	<cfset variables.instance.BuildIncomingScope  = "false" />
	<cfset variables.instance.IncomingClientName  = "" />
	
	<!--- // Outgoing Paramater holding until generate token time --->
	<cfset variables.instance.BuildOutgoingScope  = "false" />
	<cfset variables.instance.AppSid  = "" />
	<cfset variables.instance.OutgoingClientName  = "" />
	<cfset variables.instance.OutgoingParams  = StructNew() />
	
	<cffunction name="init" access="public" output="false">	
		<cfargument name="accountSid" required="true"/>
		<cfargument name="authToken" required="true"/>
		<cfset variables.instance.AccountSid = Arguments.accountSid />
		<cfset variables.instance.AuthToken = Arguments.authToken />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="buildScopeString" access="public" output="false">	
		<cfargument name="service" type="string" required="true"/>
		<cfargument name="priviledge" type="string" required="true"/>
		<cfargument name="params" type="struct" required="true"/>
		
		<cfset var scope = "scope:" & trim(Arguments.service) & ":" & trim(Arguments.priviledge) /> 
		
		<cfif ListLen(StructKeyList(Arguments.params))>
			<cfset scope = scope & "?" & generateParamString(Arguments.params)/>
		</cfif>
		
		<cfreturn trim(scope) />
	</cffunction>
	
	<cffunction name="generateParamString" access="private" output="false" returntype="string">	
		<cfargument name="params" type="struct" required="true"/>
		<cfset var str = "" />
		<cfset var p = "" />
		<cfset var key = ""/>
		<cfset var value = ""/>
			
		<cfloop collection="#Arguments.params#" item="p" >
			
			<cfset key = ToString(p.getBytes("UTF-8")) />
			<cfset value = ToString(Arguments.params[p].getBytes("UTF-8"))/>
			
			<cfset str = listAppend(str, "#key#=#value#", "&") />
		</cfloop>
		
		<cfreturn str />
	</cffunction>

	<cffunction name="allowClientOutgoing" access="public" output="false" returntype="void" hint="Allow the user of this token to make outgoing connections.">	
		<cfargument name="appSid" type="string" required="true" hint="The application to which this token grants access" />
		<cfargument name="params" type="struct" required="false" default="#StructNew()#" hint="Signed parameters that the user of this token cannot overwrite."/>
		<cfset variables.instance.BuildOutgoingScope = true />
		<cfset variables.instance.OutgoingParams = Arguments.Params />
		<cfset variables.instance.AppSid = Arguments.AppSid />
	</cffunction>
	
	<cffunction name="allowClientIncoming" access="public" output="false" returntype="void" hint="If the user of this token should be allowed to accept incoming connections then configure the TwilioCapability through this method and specify the client name.">	
		<cfargument name="clientName" type="string" required="true" />
		<cfset variables.instance.IncomingClientName = Arguments.clientName />
		<cfset variables.instance.BuildIncomingScope = true />
	</cffunction>
	
	<cffunction name="allowEventStream" access="public" output="false" returntype="void" hint="Allow the user of this token to access their event stream.">	
		<cfargument name="filters" type="struct" default="#StructNew()#" required="false" hint="key/value filters to apply to the event stream" />
		<cfset var value = StructNew() />
		<cfset var paramsJoined = "" />
		
		<cfset value["path"] = "/2010-04-01/Events" />		
				
		<cfif listLen(StructKeyList(Arguments.filters))>
			<cfset paramsJoined = generateParamString(Arguments.filters) />				
			<cfset value["params"] = paramsJoined />			
		</cfif>		
		
		<cfset variables.instance.Scopes = ListAppend(variables.instance.Scopes, buildScopeString("stream", "subscribe", value)) />
		
	</cffunction>
	
	<cffunction name="generateToken" access="public" output="false" returntype="string" hint="Generates a new token based on the credentials and permissions that previously has been granted to this token.">	
		<cfargument name="timeout" type="numeric" default="3600" required="false" />
		<cfset var payload = structNew() />
		<cfset buildIncomingScope() />
		<cfset buildOutgoingScope() />
		
		<cfset payload["iss"] = variables.instance.AccountSid />
		<!--- Force the exp to string and divide by 1000 otherwise the timestamp is too precise...thanks to Mario Rodrigues (@webauthor) for this find... --->
		<!--- Date convert local to UTC --->
		<cfset payload["exp"] = "" & ToString((dateConvert("local2utc", now()).getTime() / 1000) + val(Arguments.timeout)) />
		<cfset payload["scope"] = ListChangeDelims(variables.instance.Scopes, " ") /> 
		
		<cfreturn jwtEncode(payload, variables.instance.AuthToken) />
		
	</cffunction>
	
	<cffunction name="buildOutgoingScope" access="private" output="false" returntype="void">	
		<cfset var values = structNew() />
		<cfset var paramsJoined = "" />
		
		<cfif variables.instance.BuildOutgoingScope>
			
			<cfset values["appSid"] = variables.instance.AppSid />
			
			<!--- 
				// Outgoing takes precedence over any incoming name which
				// takes precedence over the default client name. however,
				// we do accept a null clientName
			--->
			
			<cfif len(variables.instance.OutgoingClientName)>
				<cfset values["clientName"] = variables.instance.OutgoingClientName />
			<cfelseif len(variables.instance.IncomingClientName)>
				<cfset values["clientName"] = variables.instance.IncomingClientName />	
			</cfif>
			
			<!--- Build outgoing scopes... --->
			<cfif listLen(StructKeyList(variables.instance.OutgoingParams))>
				<cfset paramsJoined = generateParamString(variables.instance.OutgoingParams) />
				
				<cfset values["appParams"] = paramsJoined />
				
			</cfif>
			
			<cfset variables.instance.Scopes = ListAppend(variables.instance.Scopes, buildScopeString("client", "outgoing", values)) />
						
		</cfif>
		
	</cffunction>

	<cffunction name="buildIncomingScope" access="private" output="false" returntype="void">	
		<cfset var values = structNew() />
		
		<cfif variables.instance.BuildIncomingScope>
			
			<cfif len(variables.instance.IncomingClientName)>
				<cfset values["clientName"] = variables.instance.IncomingClientName />
			<cfelse>
				<cfthrow message="No client name set." />	
			</cfif>
			
			<cfset variables.instance.Scopes = ListAppend(variables.instance.Scopes, buildScopeString("client", "incoming", values)) />
						
		</cfif>
		
	</cffunction>
	
	<cffunction name="jwtEncode" access="private" output="false" returntype="string">	
		<cfargument name="payload" type="struct" required="true" />
		<cfargument name="key" type="string" required="true" />
		
		<cfset var header = structNew() />
		<cfset var segments = "" />
		<cfset var signingInput = "" />
		<cfset var signature = "" />
		
		
		<cfset header["typ"] = "JWT" />
		<cfset header["alg"] = "HS256" />
		
		<cfset segments = ListAppend(segments, encodeBase64(jsonEncode(header)), ".") />
		<cfset segments = ListAppend(segments, encodeBase64(jsonEncode(payload)), ".") />
		
		<cfset signingInput = segments />
		<cfset signature = sign(signingInput, key) />
		
		<cfset segments = ListAppend(segments, signature, ".") />
		
		<cfreturn segments />
	</cffunction>	
	
	
	<cffunction name="jsonEncode" access="public" output="false" returntype="string" hint="">	
		<cfargument name="object" type="any" required="true" />
		<cfset var json = SerializeJSON(Arguments.object) />
		<cfset json = replace(json, "/", "\\/", "all") />
		<cfreturn json />
	</cffunction>
	
	<cffunction name="encodeBase64" access="public" output="false" returntype="string" hint="">	
		<cfargument name="string" type="any" required="true" />
		<cfreturn ToBase64(Arguments.String) />
	</cffunction>
	
	<cffunction name="sign" returntype="string" access="private" output="false">
		<cfargument name="signMessage" type="string" required="true" />
		<cfargument name="signKey" type="string" required="true" />
		
		<cfset var jMsg = JavaCast("string",Arguments.signMessage).getBytes("utf-8") />
		<cfset var jKey = JavaCast("string",Arguments.signKey).getBytes("utf-8") />
		<cfset var key = createObject("java","javax.crypto.spec.SecretKeySpec") />
		<cfset var mac = createObject("java","javax.crypto.Mac") />
		<cfset key = key.init(jKey,"HmacSHA256") />
		<cfset mac = mac.getInstance(key.getAlgorithm()) />
		<cfset mac.init(key) />
		<cfset mac.update(jMsg) />	
		<cfreturn ToBase64(mac.doFinal()) />
	</cffunction>

</cfcomponent>
