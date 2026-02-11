Class {
	#name : 'CIGSDL3TrayScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3TrayScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	targetArgument := #(#SDL_Tray #*).
	firstKeywordSubstringsToRemove := #('Tray').
	targetClass := self class environment classNamed: #SDL3Tray.
	theWord := 'tray'.
	excludedSelectors := #().
	explicitRenames := {
		} asOrderedDictionary
]
