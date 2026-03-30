Class {
	#name : 'CIGSDL3AudioDeviceScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3-Own-ForwardingAPI',
	#package : 'CIG-SDL3-Own',
	#tag : 'ForwardingAPI'
}

{ #category : 'converting' }
CIGSDL3AudioDeviceScripts >> forwardingMethodCategory [

	^ #accessing
]

{ #category : 'converting' }
CIGSDL3AudioDeviceScripts >> forwardingMethodMessageSendFor: each [

	^ String streamContents: [ :stream |
		each key selector keywords with: ({ 'id' }, each key argumentNames allButFirst)
			do: [ :a :b | stream << a; space; << b; space ] ]
]

{ #category : 'initialization' }
CIGSDL3AudioDeviceScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	"SDL3 only has DeviceID, an uint, so SDL3AudioDevice is created manually."

	targetArgument := #(#SDL_AudioDeviceID).
	firstKeywordSubstringsToRemove := #('AudioDevice').
	targetClass := self class environment classNamed: #SDL3AudioDevice.
	theWord := 'devid'.
	excludedSelectors := #().
	explicitRenames := {
		#audioDevicePaused -> #isPaused
		} asOrderedDictionary
]
