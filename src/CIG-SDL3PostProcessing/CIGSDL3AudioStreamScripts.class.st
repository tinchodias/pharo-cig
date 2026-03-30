Class {
	#name : 'CIGSDL3AudioStreamScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3AudioStreamScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	targetArgument := #(#SDL_AudioStream #*).
	firstKeywordSubstringsToRemove := #('AudioStream').
	targetClass := self class environment classNamed: #SDL3AudioStream.
	theWord := 'stream'.
	excludedSelectors := #().
	explicitRenames := {
		#device -> #deviceID.
		#audioDevicePaused -> #isDevicePaused

		} asOrderedDictionary
]
