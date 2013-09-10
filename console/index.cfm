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
<html>
	<head>
		<title>CFML Test Console</title>
		<link rel="stylesheet" href="../styles.css" type="text/css" media="all" />
		<link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.13/themes/base/jquery-ui.css" type="text/css" media="all" />
		<script src="scripts/jquery-1.6.2.min.js" type="text/javascript"></script>
		<script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.13/jquery-ui.min.js" type="text/javascript"></script>
		<script src="script.js" type="text/javascript"></script>
	</head>
	<body>

<cffile action="read" file="#expandPath("api.twilio.com.xml")#" variable="wadl" />
<cfset wadl = XmlParse(wadl) />

<cfset categories = StructNew() />



<cfoutput>
	<cfloop from="1" to="#ArrayLen(wadl.application.resources.resource)#" index="r" >
		<cfset cat = wadl.application.resources.resource[r].method["apigee:tags"]["apigee:tag"].XmlText/>
		<cfif NOT StructKeyExists(categories, cat)>
			<cfset categories[cat] = ArrayNew(1) />
		</cfif>

		<cfset ArrayAppend(categories[cat], r) />

	</cfloop>
	<h1>Twilio CFML Test Console</h1>
		<div id="console">
			<div id="options">
				<cfloop collection="#categories#" item="c">
				<h3><a href="##">#c#</a></h3>
				<div>
					<p>
						<ul>
							<cfloop array="#categories[c]#" index="r">
							<li><a href="Panel.cfm?resource=#r#" class="add-tab" rel="#wadl.application.resources.resource[r].method.XmlAttributes["apigee:displayName"]#">#wadl.application.resources.resource[r].method.XmlAttributes["apigee:displayName"]#</a></li>
							</cfloop>
						</ul>
					</p>
				</div>
				</cfloop>
			</div>
			<div id="workspace">
				<div id="workspace-tabs">
					<ul>
						<li><a href="##tabs-0">Settings</a></li>
					</ul>
					<div id="tabs-0">
						<p>
							<cfoutput>
							Prior to making any requests input your AccountSid and AuthToken below.  You can also update the TwilioSettings.cfm file and the values will be pulled from there.
							<table>
								<tr>
									<td>Account Sid:</td>
									<td><input type="text" value="#REQUEST.AccountSid#" id="accountsid"/></td>
								</tr>
								<tr>
									<td>Auth Token:</td>
									<td><input type="text" value="#REQUEST.AuthToken#" id="authtoken"/></td>
								</tr>
								<tr>
									<td>Default Format:</td>
									<td>
											<select id="defaultformat">
												<option value="xml">xml</option>
												<option value="json">json</option>
											</select>
										</td>
								</tr>	
							</table>
							</cfoutput>						 		
						</p>
					</div>			
				</div>
			</div>
		</div>
		<div class="clear"></div>		
	</body>
</html>
</cfoutput>