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

<cfset resource = wadl.application.resources.resource[URL.Resource]/>
<cfoutput>
<h2>#resource.method.XmlAttributes["apigee:displayName"]#</h2>
<h3>HTTP Method Used: #resource.method.XmlAttributes.Name#</h3>
<h4>#resource.method.doc.XmlText# <a href="#resource.method.doc.XmlAttributes["apigee:url"]#" target="_blank">View Twilio Docs</a></h4>
<cfset id = createUUID() />
<form id="#id#" action="/" method="post">
	<input type="hidden" name="resourceID" value="#URL.Resource#" />
	<cfif StructKeyExists(resource, "param")>
	
<table>
	<cfloop from="1" to="#ArrayLen(resource.param)#" index="p">
	<cfif resource.param[p].XmlAttributes.name NEQ "accountsid">
	
	<tr>
		<td>#resource.param[p].XmlAttributes.name#</td>
		<td>
			<cfif NOT structKeyExists(resource.param[p], "option")>
				<input name="#resource.param[p].XmlAttributes.name#" type="text" />
			<cfelse>
				<select name="#resource.param[p].XmlAttributes.name#">
					<option></option>
					<cfloop from="1" to="#ArrayLen(resource.param[p].option)#" index="o">
						<option value="#resource.param[p].option[o].XmlAttributes.value#">#resource.param[p].option[o].XmlAttributes.value#</option>
					</cfloop>
				</select>
			</cfif>
		</td>
		<td>
			<cfif structKeyExists(resource.param[p], "doc")>
				#resource.param[p].doc.XmlText#
			<cfelse>
				&nbsp;
			</cfif>
		</td>
		
	</tr>
	</cfif>
	</cfloop>
</table>
</cfif>
<input type="submit" value="Submit" style="width:100px;" />
</form>	
<div id="result-#id#" style="display:none;">LOADING!</div>
</cfoutput>