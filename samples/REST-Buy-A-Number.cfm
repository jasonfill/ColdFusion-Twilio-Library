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
<cfif not isdefined("form.fieldnames")>
	<html>
		<head>
			<title>Buy a Twilio number by area code</title>
		</head>
		<body>
			<h3>Buy a Twilio number by area code</h3>
			<cfif isdefined("msg")>
				<p class="msg"><cfoutput>#msg#</cfoutput></p>
			</cfif>
			<form method="POST">
				<label>Enter a US area code: </label>
				<input type="text" size="3" name="area_code"/>
				<input type="submit" name="submit" value="BUY"/>
			</form>
		</body>
	</html>
<cfelse>
	<cfset myParams=StructNew()>
	<cfset myParams["AreaCode"]=form.area_code>
	<cfset req = REQUEST.TwilioLib.newRequest("Accounts/{AccountSid}/IncomingPhoneNumbers", "POST", myParams) />
	<cfset xmlDoc=req.getResponse().output()>
	<cfif req.getResponse().wasSuccessful()>
		<cfset message="Thank you, you are now the proud owner of #xmlDoc.TwilioResponse.IncomingPhoneNumber.PhoneNumber.XmlText#">
	<cfelse>
		<cfset message="#xmlDoc.TwilioResponse.RestException.Message.XmlText#">
	</cfif>
	<cflocation url="#cgi.scriptname#?msg=#URLEncodedFormat(message)#">
</cfif>