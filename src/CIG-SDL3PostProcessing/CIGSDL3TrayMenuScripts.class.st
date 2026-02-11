Class {
	#name : 'CIGSDL3TrayMenuScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3TrayMenuScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	targetArgument := #(#SDL_TrayMenu #*).
	firstKeywordSubstringsToRemove := #('TrayMenu').
	targetClass := self class environment classNamed: #SDL3TrayMenu.
	theWord := 'menu'.
	excludedSelectors := #().
	explicitRenames := {
		} asOrderedDictionary
]
