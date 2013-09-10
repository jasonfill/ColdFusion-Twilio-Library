<cfcomponent displayname="ColdFusion Twilio Library" output="false">

	<cfset this.name = "#hash(getCurrentTemplatePath())#">
	
	<!--- To make things more portable lets just create a twilio mapping.... --->
	<cfset this.mappings["/twilio"] = GetDirectoryFromPath(GetCurrentTemplatePath()) & "lib">

	<cffunction name="onRequestStart" output="true">
		<cfargument name="targetPage" />	
		<!--- To make things easy to edit we just include the settings file. --->
		<cfinclude template="TwilioSettings.cfm" />
		<!--- Create a new instance of the Twilio Lib, this can be stored in the App scope or elsewhere as a singleton... --->
		<cfset REQUEST.TwilioLib = createObject("component", "twilio.TwilioLib").init(REQUEST.AccountSid, REQUEST.AuthToken, REQUEST.ApiVersion, REQUEST.ApiEndpoint) />
	</cffunction>
 
</cfcomponent>

