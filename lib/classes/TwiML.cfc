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
<cfcomponent displayname="TwiML" hint="Twilio handles instructions for calls and SMS messages in real time from web applications.">
	
	<cfset variables.instance = StructNew() />	
	<cfset variables.instance.ApiVersion = "2010-04-01" />
	<cfset variables.instance.EndPoint = "api.twilio.com" />
	<cfset variables.instance.AccountSid = "" />
	<cfset variables.instance.AutToken = "" />
	<cfset variables.instance.Response = ArrayNew(1) />
	<cfset variables.instance.NestingPermissions = StructNew() />
	
	<cffunction name="init" access="public" output="false">
		<cfargument name="accountSid" required="true"/>
		<cfargument name="authToken" required="true"/>
		<cfargument name="ApiVersion" required="false" default="#variables.instance.ApiVersion#"/>
		<cfargument name="EndPoint" required="false" default="#variables.instance.EndPoint#" />
		<cfset variables.instance.AccountSid = Arguments.accountSid />
		<cfset variables.instance.AuthToken = Arguments.authToken />
		<cfset variables.instance.ApiVersion = Arguments.ApiVersion />
		<cfset variables.instance.EndPoint = Arguments.EndPoint />
		<cfset variables.instance.NestingPermissions["dial"] = "number,conference,client" />
		<cfset variables.instance.NestingPermissions["gather"] = "say,play,pause" />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="say" access="public" output="false" returntype="any" hint="Say converts text to speech that is read back to the caller. Say is useful for development or saying dynamic text that is difficult to pre-record.">	
		<cfargument name="body" type="string" required="true" hint="The text to be converted to speech." />
		<cfargument name="voice" type="string" required="false" default="" hint="The 'voice' attribute allows you to choose a male or female voice to read text back. The default value is 'man'. Allowed Values: man, woman"/>
		<cfargument name="language" type="string" required="false" default=""  hint="The 'language' attribute allows you pick a voice with a specific language's accent and pronunciations. Twilio currently supports languages 'en' (English), 'es' (Spanish), 'fr' (French), and 'de' (German). The default is 'en'."/>
		<cfargument name="loop" type="numeric" required="false" default="1" hint="Specifies how many times you'd like the text repeated. The default is once. Specifying '0' will cause the the this text to loop until the call is hung up."/>
		<cfargument name="childOf" type="string" required="false" default="" hint="The verb that this verb should be nested within." />
		
		<cfset var properties = StructNew() />
		
		<!--- Validate the incoming arguments... --->		
		<cfif len(trim(Arguments.Voice)) AND NOT ListFindNoCase("man,woman", Arguments.Voice)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.Voice# is not a valid value for the voice attribute in say verb.  Valid values are: man or woman." />
		</cfif>
		<cfif len(trim(Arguments.language)) AND NOT ListFindNoCase("en,es,fr,de", Arguments.language)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.language# is not a valid value for the language attribute in say verb.  Valid values are: en,es,fr,de." />
		</cfif>
		<cfif len(trim(Arguments.loop)) AND val(Arguments.loop) LT 0>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.loop# is not a valid value for the loop attribute in say verb.  Valid values must be integers greater or equal to 0." />
		</cfif>

		<!--- Build the properties... --->		
		<cfset properties["voice"] = Arguments.voice />
		<cfset properties["language"] = Arguments.language />
		<cfset properties["loop"] = Arguments.loop />
		
		<!--- Append this verb... --->
		<cfset append(verb="Say", body=Arguments.body, properties=properties, childOf=Arguments.childOf) />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="play" access="public" output="false" returntype="any" hint="Plays an audio file back to the caller. Twilio retrieves the file from a URL that you provide.">	
		<cfargument name="url" type="string" required="true" hint="The URL of an audio file that Twilio will retrieve and play to the caller." />
		<cfargument name="loop" type="numeric" required="false" default="1" hint="Specifies how many times the audio file is played. The default behavior is to play the audio once. Specifying '0' will cause the the audio file to loop until the call is hung up."/>
		
		<cfset var properties = StructNew() />
		
		<!--- Validate the incoming arguments... --->		
		<cfif len(trim(Arguments.loop)) AND val(Arguments.loop) LT 0>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.loop# is not a valid value for the loop attribute in play verb.  Valid values must be integers greater or equal to 0." />
		</cfif>
		
		<!--- Build the properties... --->	
		<cfset properties["loop"] = Arguments.loop />
		
		<!--- Append this verb... --->
		<cfset append(verb="Play", body=Arguments.Url, properties=properties) />
		<!--- Return and instance of this to allow for chaining... --->
		<cfreturn this />
	</cffunction>
	
	<cffunction name="gather" access="public" output="false" returntype="any" hint="Collects digits that a caller enters into his or her telephone keypad. When the caller is done entering data, Twilio submits that data to the provided 'action' URL in an HTTP GET or POST request, just like a web browser submits data from an HTML form. If no input is received before timeout, the process moves through to the next verb in the TwiML document. ">	
		<cfargument name="action" type="string" required="true" hint="The 'action' attribute takes an absolute or relative URL as a value. When the caller has finished entering digits Twilio will make a GET or POST request to this URL including the parameters below. If no 'action' is provided, Twilio will by default make a POST request to the current document's URL." />
		<cfargument name="method" type="string" required="false" default="" hint="The 'method' attribute takes the value 'GET' or 'POST'. This tells Twilio whether to request the 'action' URL via HTTP GET or POST. This attribute is modeled after the HTML form 'method' attribute. 'POST' is the default value."/>
		<cfargument name="timeout" type="string" required="false" default=""  hint="The 'timeout' attribute sets the limit in seconds that Twilio will wait for the caller to press another digit before moving on and making a request to the 'action' URL. For example, if 'timeout' is '10', Twilio will wait ten seconds for the caller to press another key before submitting the previously entered digits to the 'action' URL. Twilio waits until completing the execution of all nested verbs before beginning the timeout period."/>
		<cfargument name="finishOnKey" type="string" required="false" default="" hint="The 'finishOnKey' attribute lets you choose one value that submits the received data when entered."/>
		<cfargument name="numDigits" type="string" required="false" default="" hint="The 'numDigits' attribute lets you set the number of digits you are expecting, and submits the data to the 'action' URL once the caller enters that number of digits. For example, one might set 'numDigits' to '5' and ask the caller to enter a 5 digit zip code. When the caller enters the fifth digit of '94117', Twilio will immediately submit the data to the 'action' URL."/>
		
		<cfset var properties = StructNew() />
		
		<!--- Validate the incoming arguments... --->		
		<cfif len(trim(Arguments.Method)) AND NOT ListFindNoCase("GET,POST", Arguments.Method)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.Method# is not a valid value for the method attribute in gather verb.  Valid values are: get or post." />
		</cfif>
		<cfif len(trim(Arguments.finishOnKey)) AND NOT ListFindNoCase("0,1,2,3,4,5,6,7,8,9,##,*", Arguments.finishOnKey)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.finishOnKey# is not a valid value for the finishOnKey attribute in gather verb.  Valid values are: any digit, ## or *." />
		</cfif>
		<cfif len(trim(Arguments.timeout)) AND val(Arguments.timeout) LTE 0>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.timeout# is not a valid value for the timeout attribute in gather verb.  Valid values must be positive integers." />
		</cfif>
		<cfif len(trim(Arguments.numDigits)) AND val(Arguments.numDigits) LT 1>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.numDigits# is not a valid value for the numDigits attribute in gather verb.  Valid values must be integers greater or equal to 1." />
		</cfif>		
		
		<!--- Build the properties... --->			
		<cfset properties["action"] = Arguments.action />
		<cfset properties["method"] = Arguments.method />
		<cfset properties["timeout"] = Arguments.timeout />
		<cfset properties["finishOnKey"] = Arguments.finishOnKey />
		<cfset properties["numDigits"] = Arguments.numDigits />
		
		<!--- Append this verb... --->
		<cfset append(verb="Gather", body="", properties=properties) />
		<!--- Return and instance of this to allow for chaining... --->
		<cfreturn this />
	</cffunction>
	
	<cffunction name="record" access="public" output="false" returntype="any" hint="Records the caller's voice and returns to you the URL of a file containing the audio recording. You can optionally generate text transcriptions of recorded calls by setting the 'transcribe' attribute of the <Record> verb to 'true'.">	
		<cfargument name="action" type="string" required="true" default="" hint="The 'action' attribute takes an absolute or relative URL as a value. When recording is finished Twilio will make a GET or POST request to this URL including the parameters below. If no 'action' is provided, <Record> will default to requesting the current document's URL." />
		<cfargument name="method" type="string" required="false" default="" hint="The 'method' attribute takes the value 'GET' or 'POST'. This tells Twilio whether to request the 'action' URL via HTTP GET or POST. This attribute is modeled after the HTML form 'method' attribute. 'POST' is the default value." />
		<cfargument name="timeout" type="string" required="false" default="" hint="The 'timeout' attribute tells Twilio to end the recording after a number of seconds of silence has passed. The default is 5 seconds." />
		<cfargument name="finishOnKey" type="string" required="false" default="" hint="The 'finishOnKey' attribute lets you choose a set of digits that end the recording when entered." />
		<cfargument name="maxLength" type="string" required="false" default="" hint="The 'maxLength' attribute lets you set the maximum length for the recording in seconds. If you set 'maxLength' to '30', the recording will automatically end after 30 seconds of recorded time has elapsed. This defaults to 3600 seconds (one hour) for a normal recording and 120 seconds (two minutes) for a transcribed recording." />
		<cfargument name="transcribe" type="string" required="false" default="" hint="The 'transcribe' attribute tells Twilio that you would like a text representation of the audio of the recording. Twilio will pass this recording to our speech-to-text engine and attempt to convert the audio to human readable text. " />
		<cfargument name="transcribeCallback" type="string" required="false" default="" hint="The 'transcribeCallback' attribute is used in conjunction with the 'transcribe' attribute. It allows you to specify a URL to which Twilio will make an asynchronous POST request when the transcription is complete." />
		<cfargument name="playBeep" type="string" required="false" default="" hint="The 'playBeep' attribute allows you to toggle between playing a sound before the start of a recording. If you set the value to 'false', no beep sound will be played." />
		
		<cfset var properties = StructNew() />
		
		<!--- Validate the incoming arguments... --->		
		<cfif len(trim(Arguments.Method)) AND NOT ListFindNoCase("GET,POST", Arguments.Method)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.Method# is not a valid value for the method attribute in record verb.  Valid values are: get or post." />
		</cfif>
		<cfif len(trim(Arguments.timeout)) AND val(Arguments.timeout) LTE 0>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.timeout# is not a valid value for the timeout attribute in record verb.  Valid values must be positive integers." />
		</cfif>
		<cfif len(trim(Arguments.finishOnKey)) AND NOT REFind("[0-9\*\##]*", Arguments.finishOnKey)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.finishOnKey# is not a valid value for the finishOnKey attribute in record verb.  Valid values are: any digit, ## or *." />
		</cfif>	
		<cfif len(trim(Arguments.maxLength)) AND val(Arguments.maxLength) LTE 1>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.maxLength# is not a valid value for the maxLength attribute in record verb.  Valid values must be integers greater than 1." />
		</cfif>
		<cfif len(trim(Arguments.Transcribe)) AND NOT ListFindNoCase("true,false", Arguments.Transcribe)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.Transcribe# is not a valid value for the transcribe attribute in record verb.  Valid values are: true or false." />
		</cfif>	
		<cfif len(trim(Arguments.PlayBeep)) AND NOT ListFindNoCase("true,false", Arguments.PlayBeep)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.PlayBeep# is not a valid value for the playBeep attribute in record verb.  Valid values are: true or false." />
		</cfif>
		
		<!--- Build the properties... --->
		<cfset properties["action"] = Arguments.action />
		<cfset properties["method"] = Arguments.method />
		<cfset properties["timeout"] = Arguments.timeout />
		<cfset properties["finishOnKey"] = Arguments.finishOnKey />
		<cfset properties["maxLength"] = Arguments.maxLength />
		<cfset properties["transcribe"] = Arguments.transcribe />
		<cfset properties["transcribeCallback"] = Arguments.transcribeCallback />
		<cfset properties["playBeep"] = Arguments.playBeep />
		
		<!--- Append this verb... --->
		<cfset append(verb="Record", body="", properties=properties) />
		<!--- Return and instance of this to allow for chaining... --->
		<cfreturn this />
	</cffunction>
	
	<cffunction name="sms" access="public" output="false" returntype="any" hint="Sends an SMS message to a phone number during a phone call.">	
		<cfargument name="to" type="string" required="false" default="" hint="The 'to' attribute takes a valid phone number as a value. Twilio will send an SMS message to this number. When sending an SMS during an incoming call, 'to' defaults to the caller. When sending an SMS during an outgoing call, 'to' defaults to the called party. The value of 'to' must be a valid phone number. " />
		<cfargument name="from" type="string" required="false" default="" hint="The 'from' attribute takes a valid phone number as an argument. This number must be a phone number that you've purchased from or ported to Twilio. When sending an SMS during an incoming call, 'from' defaults to the called party. When sending an SMS during an outgoing call, 'from' defaults to the calling party. This number must be an SMS-capable local phone number assigned to your account." />
		<cfargument name="action" type="string" required="false" default="" hint="The 'action' attribute takes a URL as an argument. After processing the <Sms> verb, Twilio will make a GET or POST request to this URL with the form parameters 'SmsStatus' and 'SmsSid'. Using an 'action' URL, your application can receive synchronous notification that the message was successfully enqueued." />
		<cfargument name="method" type="string" required="false" default="" hint="The 'method' attribute takes the value 'GET' or 'POST'. This tells Twilio whether to request the 'action' URL via HTTP GET or POST. This attribute is modeled after the HTML form 'method' attribute. 'POST' is the default value." />
		<cfargument name="statusCallback" type="string" required="false" default="" hint="The 'statusCallback' attribute takes a URL as an argument. When the SMS message is actually sent, or if sending fails, Twilio will make an asynchronous POST request to this URL with the parameters 'SmsStatus' and 'SmsSid'. Note, 'statusCallback' always uses HTTP POST to request the given url." />
		
		<cfset var properties = StructNew() />
		
		<!--- Validate the incoming arguments... --->		
		<cfif len(trim(Arguments.to)) AND NOT isValid("telephone", Arguments.to)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.to# is not a valid value for the to attribute in sms verb.  Values must be valid phone numbers." />
		</cfif>
		<cfif len(trim(Arguments.from)) AND NOT isValid("telephone", Arguments.from)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.from# is not a valid value for the from attribute in sms verb.  Values must be valid phone numbers." />
		</cfif>	
		<cfif len(trim(Arguments.Method)) AND NOT ListFindNoCase("GET,POST", Arguments.Method)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.Method# is not a valid value for the method attribute in record verb.  Valid values are: get or post." />
		</cfif>
		
		<!--- Build the properties... --->
		<cfset properties["to"] = Arguments.to />
		<cfset properties["from"] = Arguments.from />
		<cfset properties["action"] = Arguments.action />
		<cfset properties["method"] = Arguments.method />
		<cfset properties["statusCallback"] = Arguments.statusCallback />
		
		<!--- Append this verb... --->
		<cfset append(verb="Sms", body="", properties=properties) />
		<!--- Return and instance of this to allow for chaining... --->
		<cfreturn this />
	</cffunction>
	
	<cffunction name="dial" access="public" output="false" returntype="any" hint="Connects the current caller to an another phone. If the called party picks up, the two parties are connected and can communicate until one hangs up. If the called party does not pick up, if a busy signal is received, or if the number doesn't exist, the dial verb will finish.">	
		<cfargument name="number" type="string" required="false" default="" hint="The phone number to dial." />
		<cfargument name="action" type="string" required="true" default="" hint="The 'action' attribute takes a URL as an argument. When the dialed call ends, Twilio will make a GET or POST request to this URL including the parameters below." />
		<cfargument name="method" type="string" required="false" default="" hint="The 'method' attribute takes the value 'GET' or 'POST'. This tells Twilio whether to request the 'action' URL via HTTP GET or POST. This attribute is modeled after the HTML form 'method' attribute. 'POST' is the default value." />
		<cfargument name="timeout" type="string" required="false" default="" hint="The 'timeout' attribute sets the limit in seconds that is waited for the called party to answer the call. Basically, how long should Twilio let the call ring before giving up and reporting 'no-answer' as the 'DialCallStatus'." />
		<cfargument name="hangupOnStar" type="string" required="false" default="false" hint="The 'hangupOnStar' attribute lets the calling party hang up on the called party by pressing the '*' key on his phone. When two parties are connected using <Dial>, Twilio blocks execution of further verbs until the caller or called party hangs up. This feature allows the calling party to hang up on the called party without having to hang up her phone and ending her TwiML processing session. When the caller presses '*' Twilio will hang up on the called party. If an 'action' URL was provided, Twilio submits 'completed' as the 'DialCallStatus' to the URL and processes the response. If no 'action' was provided Twilio will continue on to the next verb in the current TwiML document." />
		<cfargument name="timeLimit" type="string" required="false" default="" hint="The 'timeLimit' attribute sets the maximum duration of the <Dial> in seconds. For example, by setting a time limit of 120 seconds <Dial> will hang up on the called party automatically two minutes into the phone call. By default, there is a four hour time limit set on calls." />
		<cfargument name="callerId" type="string" required="false" default="" hint="The 'callerId' attribute lets you specify the caller ID that will appear to the called party when Twilio calls. By default, when you put a <Dial> in your TwiML response to Twilio's inbound call request, the caller ID that the dialed party sees is the inbound caller's caller ID." />
		
		<cfset var properties = StructNew() />
		
		<!--- Validate the incoming arguments... --->		
		<cfif len(trim(Arguments.number)) AND NOT isValid("telephone", Arguments.number)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.number# is not a valid value for the number attribute in dial verb.  Values must be valid phone numbers." />
		</cfif>
		<cfif len(trim(Arguments.Method)) AND NOT ListFindNoCase("GET,POST", Arguments.Method)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.Method# is not a valid value for the method attribute in dial verb.  Valid values are: get or post." />
		</cfif>
		<cfif len(trim(Arguments.timeout)) AND val(Arguments.timeout) LTE 0>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.timeout# is not a valid value for the timeout attribute in dial verb.  Valid values must be positive integers." />
		</cfif>
		<cfif len(trim(Arguments.hangupOnStar)) AND NOT ListFindNoCase("true,false", Arguments.hangupOnStar)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.hangupOnStar# is not a valid value for the hangupOnStar attribute in dial verb.  Valid values are: true or false." />
		</cfif>	
		<cfif len(trim(Arguments.timeLimit)) AND val(Arguments.timeLimit) LTE 0>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.timeLimit# is not a valid value for the timeLimit attribute in dial verb.  Valid values must be positive integers." />
		</cfif>
		<cfif len(trim(Arguments.callerId)) AND NOT isValid("telephone", Arguments.callerId)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.callerId# is not a valid value for the callerId attribute in dial verb.  Values must be valid phone numbers." />
		</cfif>
		
		<!--- Build the properties... --->		
		<cfset properties["action"] = Arguments.action />
		<cfset properties["method"] = Arguments.method />
		<cfset properties["timeout"] = Arguments.timeout />
		<cfset properties["hangupOnStar"] = Arguments.hangupOnStar />
		<cfset properties["timeLimit"] = Arguments.timeLimit />
		<cfset properties["callerId"] = Arguments.callerId />
		
		<!--- Append this verb... --->
		<cfset append(verb="Dial", body=Arguments.number, properties=properties) />
		<!--- Return and instance of this to allow for chaining... --->
		<cfreturn this />
	</cffunction>
	
	<cffunction name="number" access="public" output="false" returntype="any" hint="The <Dial> verb's <Number> noun specifies a phone number to dial. Using the noun's attributes you can specify particular behaviors that Twilio should apply when dialing the number.">	
		<cfargument name="number" type="string" required="true" default="" hint="The phone number to dial." />
		<cfargument name="sendDigits" type="string" required="false" default="" hint="The 'sendDigits' attribute tells Twilio to play DTMF tones when the call is answered. This is useful when dialing a phone number and an extension. Twilio will dial the number, and when the automated system picks up, send the DTMF tones to connect to the extension." />
		<cfargument name="url" type="string" required="false" default="" hint="The 'url' attribute allows you to specify a url for a TwiML document that will run on the called party's end, after she answers, but before the parties are connected. You can use this TwiML to privatly play or say information to the called party, or provide a chance to decline the phone call using <Gather> and <Hangup>. The current caller will continue to hear ringing while the TwiML document executes on the other end. TwiML documents executed in this manner are not allowed to contain the <Dial> verb." />
		<cfargument name="childOf" type="string" required="false" default="" hint="The verb that this verb should be nested within." />
		
		<cfset var properties = StructNew() />
		
		<!--- Validate the incoming arguments... --->		
		<cfif len(trim(Arguments.number)) AND NOT isValid("telephone", Arguments.number)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.number# is not a valid value for the number attribute in number verb.  Values must be valid phone numbers." />
		</cfif>
		<cfif len(trim(Arguments.sendDigits)) AND NOT isValid("telephone", Arguments.sendDigits)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.sendDigits# is not a valid value for the sendDigits attribute in number verb.  Valid values are any digits." />
		</cfif>
		
		
		<!--- Build the properties... --->		
		<cfset properties["sendDigits"] = Arguments.sendDigits />
		<cfset properties["url"] = Arguments.url />
		
		<!--- Append this verb... --->
		<cfset append(verb="Number", body=Arguments.number, properties=properties, childOf=Arguments.childOf) />
		<!--- Return and instance of this to allow for chaining... --->
		<cfreturn this />
	</cffunction>
	
	<cffunction name="client" access="public" output="false" returntype="any" hint="The <Dial> verb's <Client> noun allows you to connect to a conference room. Much like how the <Number> noun allows you to connect to another phone number, the <Conference> noun allows you to connect to a named conference room and talk with the other callers who have also connected to that room.">	
		<cfargument name="clientName" type="string" required="true" default="" hint="Name of the client to connect to." />
		<cfargument name="childOf" type="string" required="false" default="dial" hint="The verb that this verb should be nested within." />
		
		<cfset var properties = StructNew() />
		
		
		
		<!--- Append this verb... --->
		<cfset append(verb="Client", body=Arguments.clientName, properties=properties, childOf=Arguments.childOf) />
		<!--- Return and instance of this to allow for chaining... --->
		<cfreturn this />
	</cffunction>
	
	<cffunction name="conference" access="public" output="false" returntype="any" hint="The <Dial> verb's <Conference> noun allows you to connect to a conference room. Much like how the <Number> noun allows you to connect to another phone number, the <Conference> noun allows you to connect to a named conference room and talk with the other callers who have also connected to that room.">	
		<cfargument name="roomName" type="string" required="true" default="" hint="Name of the conference room to connect to." />
		<cfargument name="muted" type="string" required="false" default="" hint="The 'muted' attribute lets you specify whether a participant can speak on the conference. If this attribute is set to 'true', the participant will only be able to listen to people on the conference. This attribute defaults to 'false'." />
		<cfargument name="beep" type="string" required="false" default="" hint="The 'beep' attribute lets you specify whether a notification beep is played to the conference when a participant joins or leaves the conference. This defaults to 'true'." />
		<cfargument name="startConferenceOnEnter" type="string" required="false" default="" hint="This attribute tells a conference to start when this participant joins the conference, if it is not already started. This is true by default. If this is false and the participant joins a conference that has not started, they are muted and hear background music until a participant joins where startConferenceOnEnter is true. This is useful for implementing moderated conferences." />
		<cfargument name="endConferenceOnExit" type="string" required="false" default="" hint="If a participant has this attribute set to 'true', then when that participant leaves, the conference ends and all other participants drop out. This defaults to 'false'. This is useful for implementing moderated conferences that bridge two calls and allow either call leg to continue executing TwiML if the other hangs up." />
		<cfargument name="waitUrl" type="string" required="false" default="" hint="The 'waitUrl' attribute lets you specify a URL for music that plays before the conference has started." />
		<cfargument name="waitMethod" type="string" required="false" default="" hint="This attribute indicates which HTTP method to use when requesting 'waitUrl'. It defaults to 'POST'. Be sure to use 'GET' if you are directly requesting static audio files such as WAV or MP3 files so that Twilio properly caches the files." />
		<cfargument name="maxParticipants" type="numeric" required="false" default="" hint="This attribute indicates the maximum number of participants you want to allow within a named conference room. The default maximum number of participants is 40. The value must be a positive integer less than or equal to 40." />
		<cfargument name="childOf" type="string" required="false" default="dial" hint="The verb that this verb should be nested within." />
		
		<cfset var properties = StructNew() />
		
		<!--- Validate the incoming arguments... --->		
		<cfif len(trim(Arguments.muted)) AND NOT ListFindNoCase("true,false", Arguments.muted)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.muted# is not a valid value for the muted attribute in conference verb.  Valid values are: true or false." />
		</cfif>
		<cfif len(trim(Arguments.beep)) AND NOT ListFindNoCase("true,false", Arguments.beep)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.beep# is not a valid value for the beep attribute in conference verb.  Valid values are: true or false." />
		</cfif>
		<cfif len(trim(Arguments.startConferenceOnEnter)) AND NOT ListFindNoCase("true,false", Arguments.startConferenceOnEnter)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.startConferenceOnEnter# is not a valid value for the startConferenceOnEnter attribute in conference verb.  Valid values are: true or false." />
		</cfif>
		<cfif len(trim(Arguments.endConferenceOnExit)) AND NOT ListFindNoCase("true,false", Arguments.endConferenceOnExit)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.endConferenceOnExit# is not a valid value for the endConferenceOnExit attribute in conference verb.  Valid values are: true or false." />
		</cfif>
		<cfif len(trim(Arguments.muted)) AND NOT ListFindNoCase("true,false", Arguments.muted)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.muted# is not a valid value for the muted attribute in conference verb.  Valid values are: true or false." />
		</cfif>
		<cfif len(trim(Arguments.waitMethod)) AND NOT ListFindNoCase("GET,POST", Arguments.waitMethod)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.waitMethod# is not a valid value for the waitMethod attribute in conference verb.  Valid values are: get or post." />
		</cfif>
		<cfif len(trim(Arguments.maxParticipants)) AND (val(Arguments.maxParticipants) LTE 0 OR val(Arguments.maxParticipants) GT 40)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.maxParticipants# is not a valid value for the maxParticipants attribute in conference verb.  Valid values must integers greater than 0 and less than or equal to 40." />
		</cfif>
		
		<!--- Build the properties... --->				
		<cfset properties["muted"] = Arguments.muted />
		<cfset properties["beep"] = Arguments.beep />
		<cfset properties["startConferenceOnEnter"] = Arguments.startConferenceOnEnter />
		<cfset properties["endConferenceOnExit"] = Arguments.endConferenceOnExit />
		<cfset properties["waitUrl"] = Arguments.waitUrl />
		<cfset properties["waitMethod"] = Arguments.waitMethod />
		<cfset properties["maxParticipants"] = Arguments.maxParticipants />
		
		<!--- Append this verb... --->
		<cfset append(verb="Conference", body=Arguments.roomName, properties=properties, childOf=Arguments.childOf) />
		<!--- Return and instance of this to allow for chaining... --->
		<cfreturn this />
	</cffunction>
	
	<cffunction name="hangup" access="public" output="false" returntype="any" hint="Ends a call. If used as the first verb in a TwiML response it does not prevent Twilio from answering the call and billing your account. ">	
		<cfset var properties = StructNew() />
		<cfset append(verb="Hangup") />
		<!--- Return and instance of this to allow for chaining... --->
		<cfreturn this />
	</cffunction>

	<cffunction name="redirect" access="public" output="false" returntype="any" hint="Transfers control of a call to the TwiML at a different URL. All verbs after this method are unreachable and ignored.">	
		<cfargument name="url" type="string" required="true" hint="An absolute or relative URL for a different TwiML document." />
		<cfargument name="method" type="string" required="false" default="" hint="The 'method' attribute takes the value 'GET' or 'POST'. This tells Twilio whether to request the <Redirect> URL via HTTP GET or POST. 'POST' is the default." />

		<cfset var properties = StructNew() />

		<!--- Validate the incoming arguments... --->		
		<cfif len(trim(Arguments.method)) AND NOT ListFindNoCase("GET,POST", Arguments.method)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.method# is not a valid value for the method attribute in redirect verb.  Valid values are: get or post." />
		</cfif>
		
		<!--- Build the properties... --->
		<cfset properties["method"] = Arguments.method />
		
		<!--- Append this verb... --->
		<cfset append(verb="Redirect", body=Arguments.url, properties=properties) />
		<!--- Return and instance of this to allow for chaining... --->
		<cfreturn this />
	</cffunction>
	
	<cffunction name="reject" access="public" output="false" returntype="any" hint="Rejects an incoming call to your Twilio number without billing you. This is very useful for blocking unwanted calls.  If the first verb in a TwiML document is <Reject>, Twilio will not pick up the call. The call ends with a status of 'busy' or 'no-answer', depending on the verb's 'reason' attribute. Any verbs after <Reject> are unreachable and ignored.">	
		<cfargument name="reason" type="string" required="false" default="" hint="The reason attribute takes the values 'rejected' and 'busy.' This tells Twilio what message to play when rejecting a call. Selecting 'busy' will play a busy signal to the caller, while selecting 'rejected' will play a standard not-in-service response. If this attribute's value isn't set, the default is 'rejected.'" />
		
		<cfset var properties = StructNew() />
		
		<!--- Validate the incoming arguments... --->		
		<cfif len(trim(Arguments.reason)) AND NOT ListFindNoCase("rejected,busy", Arguments.reason)>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.reason# is not a valid value for the reason attribute in reject verb.  Valid values are: rejected or busy." />
		</cfif>
		
		<!--- Build the properties... --->
		<cfset properties["reason"] = Arguments.reason />
		
		<!--- Append this verb... --->
		<cfset append(verb="Reject", body="", properties=properties) />
		<!--- Return and instance of this to allow for chaining... --->
		<cfreturn this />
	</cffunction>
	
	<cffunction name="pause" access="public" output="false" returntype="any" hint="Waits silently for a specific number of seconds. If first verb in a TwiML document, Twilio will wait the specified number of seconds before picking up the call.">	
		<cfargument name="length" type="numeric" required="false" default="1" hint="The 'length' attribute specifies how many seconds Twilio will wait silently before continuing on." />
		<cfargument name="childOf" type="string" required="false" default="" hint="The verb that this verb should be nested within." />
		
		<cfset var properties = StructNew() />
		
		<!--- Validate the incoming arguments... --->		
		<cfif len(trim(Arguments.length)) AND val(Arguments.length) LTE 0>
			<cfthrow type="TwilioAttributeException" detail="#Arguments.length# is not a valid value for the length attribute in pause verb.  Valid values must integers greater than 0." />
		</cfif>
		
		<!--- Build the properties... --->			
		<cfset properties["length"] = Arguments.length />
		<!--- Lets append this verb... --->
		<cfset append(verb="Pause", body="", properties=properties, childOf=Arguments.childOf) />
		<!--- Return and instance of this to allow for chaining... --->
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getResponseData" access="public" output="false" returntype="array" hint="">	
		<cfreturn variables.instance.Response />
	</cffunction>
	
	<cffunction name="getResponseXml" access="public" output="false" returntype="string" hint="">	
		<cfset var i = "" />
		<cfset var newElement = "" />
		<cfset var responseDoc = XmlNew() />
		<cfset var responseRoot = XmlElemNew( responseDoc, "", "Response" ) />
		<cfset responseDoc.XmlRoot = responseRoot />
	
		<cfloop array="#getResponseData()#" index="i">
			<cfset buildResponse(responseDoc, responseDoc.Response, i) />
		</cfloop>
		
		<cfset xmlString = ToString(responseDoc)/>
		<cfset xmlString = xmlString.ReplaceAll("xmlns(:\w+)?=""[^""]*""","") />
		<cfset xmlString = xmlString.ReplaceAll(" >",">") />
		<cfset xmlString = xmlString.ReplaceAll(">#chr(10)#<","><") />
		
		<cfreturn xmlString />
	</cffunction>
	
	<cffunction name="getResponse" access="public" output="true" hint="">	
		<cfcontent reset="true" /><cfheader name="Content-type" value="text/xml" /><cfoutput>#getResponseXml()#</cfoutput>
	</cffunction>
	
	<cffunction name="buildResponse" access="private" output="false" returntype="any" hint="">	
		<cfargument name="responseDoc" />
		<cfargument name="appendTo" />
		<cfargument name="Item" />
			<cfset var newElement = XmlElemNew( Arguments.responseDoc, "", Arguments.Item.verb ) />
			<cfset var p = "" />
			<cfset var c = "" />
		
			<cfset newElement.XmlText = Arguments.Item.body/>
			<!--- Loop all the properties... --->
			<cfloop collection="#Arguments.Item.properties#" item="p">
				<cfif len(trim(Arguments.Item.properties[p]))>
					<cfset newElement.XmlAttributes[p] = Arguments.Item.properties[p] />
				</cfif>
			</cfloop>

			<!--- Now if there is a child, append it --->
			<cfloop array="#Arguments.Item.Children#" index="c">
				<cfset buildResponse(Arguments.responseDoc, newElement, c) />
			</cfloop>
		
			<cfset ArrayAppend(Arguments.AppendTo.XmlChildren, newElement) />
		
		<cfreturn Arguments.responseDoc />
	</cffunction>
	
	
	<cffunction name="append" access="private" output="false" hint="">
		<cfargument name="verb" type="string" default="" required="true" />
		<cfargument name="body" type="string" default="" required="false" />
		<cfargument name="properties" type="struct" default="#structNew()#" required="true" />
		<cfargument name="childOf" type="string" required="false" default="" hint="" />
		
		<cfset var verbData = StructNew() />
		<cfset var nestInto = "" />
		<cfset var nestIntoIdx = "0" />
		<cfset var v = "" />
		
		<cfset verbData["verb"] = Arguments.verb />
		<cfset verbData["properties"] = Arguments.properties />
		<cfset verbData["body"] = XmlFormat(Arguments.body) />
		<cfset verbData["children"] = ArrayNew(1) />
		
		<cfif NOT len(trim(Arguments.childOf))>
			<cfset ArrayAppend(variables.instance.Response, verbData) />
		<cfelse>

			<!--- Since we are nesting this, we need to figure out which index we are nesting into... --->
			<cfloop from="#ArrayLen(variables.instance.Response)#" to="1" index="v" step="-1">
				<cfif variables.instance.Response[v].verb EQ Arguments.childOf>
					<cfset nestIntoIdx = v />
					<cfbreak />
				</cfif>
			</cfloop>
			
			<cfif val(nestIntoIdx) EQ 0>
				<cfthrow type="TwilioNestingException" detail="There no #Arguments.childOf# verbs to nest #Arguments.verb# into." />
			</cfif>
			
			<cfset nestInto = variables.instance.Response[nestIntoIdx] />
				
			<cfif StructKeyExists(variables.instance.NestingPermissions, nestInto.verb)
					AND ListFindNoCase(variables.instance.NestingPermissions[nestInto.verb], Arguments.Verb)>
				<cfset ArrayAppend(variables.instance.Response[ArrayLen(variables.instance.Response)].children, verbData) />
			<cfelse>
				<cfthrow type="TwilioNestingException" detail="#Arguments.Verb# cannot be nested within #nestInto.verb#." />
			</cfif>

		</cfif>
		
	</cffunction>
	
</cfcomponent>