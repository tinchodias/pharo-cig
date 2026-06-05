Class {
	#name : 'CIGSDL3JoystickScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3JoystickScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	targetArgument := #(#SDL_Joystick #*).
	firstKeywordSubstringsToRemove := #().
	targetClass := self class environment classNamed: #SDL3Joystick.
	theWord := 'joystick'.
	excludedSelectors := #().
	explicitRenames := {
		#gUID -> #guid.
		#iD -> #id.
		#lEDJoystickRed:green:blue: -> #ledRed:green:blue:.
		#properties -> #propertiesID.
		} asOrderedDictionary
]
