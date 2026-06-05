Class {
	#name : 'CIGSDL3GamepadScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3GamepadScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	targetArgument := #(#SDL_Gamepad #*).
	firstKeywordSubstringsToRemove := #().
	targetClass := self class environment classNamed: #SDL3Gamepad.
	theWord := 'gamepad'.
	excludedSelectors := #().
	explicitRenames := {
		#iD -> #id.
		#lEDGamepadRed:green:blue: -> #ledRed:green:blue:.
		#numTouchpads -> #numberOfTouchpads.
		#properties -> #propertiesID.
		} asOrderedDictionary
]
