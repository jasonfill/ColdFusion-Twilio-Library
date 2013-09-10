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
<cffile action="read" file="#expandPath("api.twilio.com.xml")#" variable="wadl" />
<cfset wadl = XmlParse(wadl) />

<cfset categories = StructNew() />

<cfset resource = wadl.application.resources.resource[FORM.Resourceid]/>

<cfset _accountsid = FORM.accountsid />
<cfset _authtoken = FORM.authtoken />
<cfset left = "<" />
<cfset right = ">" />

<cfif StructKeyExists(FORM, 'format') AND NOT len(FORM.format)>
	<cfset FORM.format = FORM.defaultformat />	
</cfif>

<!--- Create a new instance of the Twilio Lib, this can be stored in the App scope or elsewhere as a singleton... --->
<cfset REQUEST.TwilioLib = createObject("component", "twilio.TwilioLib").init(_accountsid, _authtoken, REQUEST.ApiVersion, REQUEST.ApiEndpoint) />

<!--- Delete the fieldnames key from the struct... --->
<cfset StructDelete(FORM, "FieldNames") />
<cfset StructDelete(FORM, "accountsid") />
<cfset StructDelete(FORM, "authtoken") />
<cfset StructDelete(FORM, "resourceid") />
<cfset StructDelete(FORM, "defaultformat") />


<cfset resourceMethod = resource.method.XmlAttributes.Name/>
<cfset resourceUri = resource.XmlAttributes.Path/>

<cfif left(resourceUri, 1) EQ "/">
	<cfset resourceUri = "Accounts" & resourceUri/>
</cfif>

<!--- First loop the resource replacing any of the placeholders with the correct values... --->
<cfloop collection="#form#" item="f">
	<cfif FindNoCase("{#f#}", resourceUri) AND len(trim(FORM[f]))>
		<cfset resourceUri = ReplaceNoCase(resourceUri, "{#f#}", FORM[f]) />
		<!--- Now remove the value from the FORM struct to clean it up so it can be passed directly into the newRequst() method... --->
		<cfset StructDelete(FORM, f) />
	</cfif>
	<!--- Now, if any of the parameters are blank, delete them... --->
	<cfif StructKeyExists(FORM, f) AND NOT len(trim(FORM[f]))>
		<cfset StructDelete(FORM, f) />
	</cfif>
</cfloop>

	<cfset requestObj = REQUEST.TwilioLib.newRequest(resourceUri, resourceMethod, FORM, _accountsid, _authtoken) />
	
	<cfoutput>
  <cfsavecontent variable="cfmlcode" >
  	<h4>Request Result</h4>
		This request 
		<cfif requestObj.getResponse().wasSuccessful()>
			was <span class="success">successful</span>.
		<cfelse>
			<span class="fail">failed</span>.
		</cfif>
		<h4>CFML Code Used</h4>
		<div class="cfmlcode">
		&##60;--- Create an instance of the TwilioLib, this is a singleton so it could be persisted in the Application scope or handled via a DI engine such as ColdSpring ---&##62;
		<br/>
		&##60;cfset twilio = createObject("component", "TwilioLib").init(#_accountsid#, #_authtoken#) /&##62;
		<br/>
		<br/>		
		<cfif ListLen(StructKeyList(FORM))>
			&##60;--- Create a new structure that will hold the request parameters ---&##62;
			<br/>
			&##60;cfset rData = StructNew() /&##62;
			<br/>
			<br/>
			&##60;--- Add all the parameters to the structure ---&##62;<br/>
			<cfloop collection="#form#" item="f">
				&##60;cfset rData.#f# = #FORM[f]# /&##62;<br/>
			</cfloop>
			<br/>
		</cfif>
		&##60;--- Call the newRequest method from the TwilioLib object that was created previously, or is persisted in the application ---&##62;
		<br/>
		&##60;cfset requestObj = twilio.newRequest("#resourceUri#", "#resourceMethod#"<cfif ListLen(StructKeyList(FORM))>, rData</cfif>) /&##62;
		<br/>
		<br/>
		&##60;--- Check to see if the request was successful using the wasSuccessful method from the response object ---&##62;<br/>
		requestObj.getResponse().wasSuccessful()
		<br/>
		<br/>
		&##60;--- Get the raw text response ---&##62;
		<br/>
		requestObj.getResponse().asString()
		<br/>
		<br/>
		&##60;--- Get the response as CFML Object ---&##62;
		<br/>
		requestObj.getResponse().output()
		</div>
	</cfsavecontent>
	#cfmlcode#
	
	<h4>Raw Response - requestObj.getResponse().asString()</h4>
	<textarea style="width:100%; height:100px;">#requestObj.getResponse().asString()#</textarea>
	
	<h4>CFML Object Response - requestObj.getResponse().output()</h4>
	<cfdump var="#requestObj.getResponse().output()#" label="Response Output" expand="true" />
	
	</cfoutput>
	
