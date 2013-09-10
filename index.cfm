<html>
	<head>
		<title>Twilio CFML Library</title>
		<link rel="stylesheet" href="styles.css" type="text/css" media="all" />
	</head>
	<body class="home">
		<h1>Twilio CFML Library</h1>
		<h2>Introduction</h2>
		<p>Thank you for downloading the CFML library for <a href="http://www.twilio.com" target="_blank">Twilio</a>.  If you have made it to this point you obviously know what Twilio is and have an interest in leveraging the awesome service that they provide.  If you need more information on Twilio you can view the following links:
			<ul>
				<li><a href="http://www.twilio.com/api/" target="_blank">How It Works</a></li>
				<li><a href="http://www.twilio.com/pricing/" target="_blank">Pricing</a></li>
				<li><a href="http://www.twilio.com/docs/index" target="_blank">Documentation</a></li>
				<li><a href="http://getsatisfaction.com/twilio/" target="_blank">Support Forums</a></li>				
			</ul>
		</p>
		
		<h2>Getting Started With CFML & Twilio</h2>
		<p>The CFML library for Twilio was put together with the goal of taking the simple Twilio API and making it even easier for CFML developers to consume.</p>
		<p>
			A few things you will need to do prior to running any of the samples below:
			<ol>
				<li>Go to <a href="https://www.twilio.com/try-twilio" target="_blank">Twilio.com</a> and create your free trial account.  They will provide you with $30 in free calling credits for testing.</li>
				<li>Once you have created your account you will want to locate your AccountSid and AuthToken.  These can be found under "Developer Tools" on the Dashboard page once logging into your Twilio account.</li>
				<li>Edit the TwilioSettings.cfm template that sits along side this index.cfm page in your file sytem using the AccountSid and AuthToken from your Twilio account.</li>
				<li>Run any of the samples below and have fun with the Twilio & CFML!</li>
			</ol>
		</p>
		
		<h2>CFML Developer Tools</h2>
		<ul>
			<li><a href="console" target="_blank">CFML REST Test Console</a></li>
			<li><a href="docs" target="_blank">Documentation</a></li>
		</ul>
		
		<h2>Samples</h2>
		<ul>
			<li><a href="console">CFML Test Console</a></li>
			<li><a href="samples/Client.cfm">Generate Client Capability Token</a></li>
			<li><a href="samples/rest.cfm">Sample REST</a></li>
			<li><a href="samples/REST-Buy-A-Number.cfm">Sample REST - Purchase Phone Number</a></li>
			<li><a href="samples/rest-BadParameter.cfm">Sample REST - Bad Parameter</a></li>
			<li><a href="samples/rest-BadHttpMethod.cfm">Sample REST - Bad HTTP Method</a></li>
			<li><a href="samples/TwiML.cfm">Sample TwiML</a></li>
			<li><a href="samples/TwiML-BadInput.cfm">Sample TwiML - Bad Input</a></li>
			<li>Sample Twilio Request Validation - view the Validation.cfm file in the samples directory to see how that works.</li>		
		</ul>
		
		<h2>Future Library Enhancements</h2>
		<ul>
			<li>Realtime Call Debugger - Coming soon this will allow you to watch the TwiML being returned from your application in real-time.</li>
			<li>Integrated Logging Component - This will provide hooks for logging inside the library.</li>
		</ul>
		
		<h2>Project & Contact Information</h2>
		<p>This project is hosted on <a href="http://riaforge.org" target="_blank">RIAForge</a>.  
			<ul>
				<li>Updates and additional information can be found at <a href="http://twiliolibrary.riaforge.org" target="_blank">http://twiliolibrary.RiaForge.org</a></li>
				<li><a href="http://svn.riaforge.org/twiliolibrary/" target="_blank">Project SVN</a></li>
			</ul>
		</p>
		
		<h2>Licensing (MIT License)</h2>
		<p>Copyright (c) 2011 Jason Fill (<a href="twitter.com/jasonfill">@jasonfill</a>)</p>
		<p>Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:</p>
		<p>The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.</p>
		<p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.</p>
				
	</body>
</html>