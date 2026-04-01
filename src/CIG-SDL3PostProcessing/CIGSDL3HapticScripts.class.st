Class {
	#name : 'CIGSDL3HapticScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3HapticScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	targetArgument := #(#SDL_Haptic #*).
	firstKeywordSubstringsToRemove := #().
	targetClass := self class environment classNamed: #SDL3Haptic.
	theWord := 'haptic'.
	excludedSelectors := #().
	explicitRenames := {
		#iD -> #id.
		#numAxes -> #numberOfAxes.
		} asOrderedDictionary
]
