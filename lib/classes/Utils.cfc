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
<cfcomponent displayname="TwilioUtils">
	
	<cfset variables.instance = StructNew() />	
	<cfset variables.instance.AccoutSid = "" />
	<cfset variables.instance.AutToken = "" />

	<cffunction name="init" access="public" output="false">	
		<cfargument name="accountSid" required="true"/>
		<cfargument name="authToken" required="true"/>
		<cfset variables.instance.AccountSid = Arguments.accountSid />
		<cfset variables.instance.AuthToken = Arguments.authToken />
		<cfreturn this />
	</cffunction>
	
	<cffunction name="validateRequest" access="public" output="false" hint="Validates the request is coming from Twilio." returntype="boolean">	
		<cfargument name="CgiInfo" type="struct" required="false" default="#CGI#"/>		
		<cfargument name="HttpResponseInfo" type="struct" required="false" default="#GetHttpRequestData()#"/>		
		
			<cfset var temp = StructNew() />
		 	<cfset var x = ""/>
		 	<cfset var sortedList = ""/>
		 	<cfset var str = "" />
		  <cfset var headers = Arguments.HttpResponseInfo.headers />
		  <cfset var method =  Arguments.HttpResponseInfo.method />
		  <cfset var qString = Arguments.CgiInfo.Query_String />
		  <cfset var expectedSignature = "" />
		  <cfset var sentSignature = "" />
		  <cfset var protocol = "http://"/>	
	  	<cfset var url = ""/>
		  <cfset var postVars = ""/>
	  	
		  <cfif len(trim(qString))>
		  	<cfset qString = "?" & qString />
		  </cfif>
		  
		  <cfif method EQ "POST">
		  	<cfset postVars = preparePostVars(UrlDecode(Arguments.HttpResponseInfo.content, 'utf-8')) />
			</cfif>  
		  
		  <cfif Arguments.CgiInfo.Server_Port_Secure>
		  	<cfset protocol = "https://"/>			
			</cfif>
		  
	  	<cfset url = protocol & Arguments.CgiInfo.Server_Name & Arguments.CgiInfo.Script_Name & qString & postVars/>
			
	  	<cfset expectedSignature = generateSignature(variables.instance.AuthToken, url) />
		  	
		    
		  <cfif StructKeyExists(headers, "X-Twilio-Signature")>
		  	<cfset sentSignature = headers["X-Twilio-Signature"] />
			</cfif>	
		
			<cfif expectedSignature EQ sentSignature>
				<cfreturn 1/>
			<cfelse>
				<cfreturn 0/>
			</cfif>
	</cffunction>

	<cffunction name="preparePostVars" returntype="string" access="private" output="false">
		<cfargument name="qString" type="string" required="true" />
		<cfset var x = "" />
		<cfset var str = "" />
		<cfset var sortedList = "" />
		<cfset var temp = StructNew() />
			
		<cfloop list="#Arguments.qString#" index="x" delimiters="&">
	 		<cfset temp["#ListFirst(x, '=')#"] = ListLast(x, '=') />
	 	</cfloop>
	 	
	 	<cfset sortedList = ListSort(StructKeyList(temp), "Text") />	
	 	
	 	<cfloop list="#sortedList#" index="x" >
	 		<cfset str = str & "#x##temp[x]#" />
	 	</cfloop>

		<cfreturn str />
	</cffunction>
	
	<cffunction name="generateSignature" returntype="string" access="private" output="false">
		<cfargument name="signKey" type="string" required="true" />
		<cfargument name="signMessage" type="string" required="true" />
		<cfset var jMsg = JavaCast("string",Arguments.signMessage).getBytes("utf-8") />
		<cfset var jKey = JavaCast("string",Arguments.signKey).getBytes("utf-8") />
		<cfset var key = createObject("java","javax.crypto.spec.SecretKeySpec") />
		<cfset var mac = createObject("java","javax.crypto.Mac") />
		<cfset key = key.init(jKey,"HmacSHA1") />
		<cfset mac = mac.getInstance(key.getAlgorithm()) />
		<cfset mac.init(key) />
		<cfset mac.update(jMsg) />	
		<cfreturn ToBase64(mac.doFinal()) />
	</cffunction>
</cfcomponent>