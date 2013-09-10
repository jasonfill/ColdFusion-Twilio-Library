
<!--- Get an instance of the capability object... --->
<cfset cap = REQUEST.TwilioLib.getCapability() />

<!---
<cfset cap.allowClientIncoming("Bob") />
--->

<cfset params = StructNew() />
<!--- Allow the client outgoing by passing in the appsid --->
<cfset cap.allowClientOutgoing("AppSid", params) />

<cfset token = cap.generateToken() />

<h2>Your Token</h2>
<cfoutput>#token#</cfoutput>