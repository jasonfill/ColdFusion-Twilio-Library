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
 
<style>
	textarea{width:100%; height:100px;}
</style>

	
		<!--- Options for specifying the resource below, all of which will be transformed by the lib to a valid resource.
		Accounts/{AccountSid}
		/Accounts/{AccountSid}
		2010-04-01/Accounts/{AccountSid}
		/2010-04-01/Accounts/{AccountSid}
		
		The AccountSid could be added to in the resource as well, but the placeholder provides more flexibility.
 --->			
	
	
	<!--- Get account information... --->
	<cfset requestObj = REQUEST.TwilioLib.newRequest("Accounts/{AccountSid}", "GET") />
	
	<!---
		Check to see if the request was successful
		<cfdump var="#requestObj.getResponse().wasSuccessful()#">

		Get the raw text response:
		<cfdump var="#requestObj.getResponse().asString()#" />
		
		Get the response as a CFML Object:
		<cfdump var="#requestObj.getResponse().output()#" />  <!--- I am not 100% about this method name, any suggestions? --->
  --->
  
  <cfdump var="#requestObj.getResponse().output()#" />
	
	
	
	<!--- Send SMS Sample 	
	<cfset requestObj = REQUEST.TwilioLib.newRequest("Accounts/{AccountSid}/SMS/Messages", "POST", {From = "(616) 606-0978", 
																																				 							 To = "2053964533", 
																																											 Body = "Hello World!"}) />
	<cfdump var="#requestObj.getResponse().output()#" />
	--->																																				 


	