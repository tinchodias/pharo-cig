Class {
	#name : 'CIGSDL3TrayEntryScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3TrayEntryScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	targetArgument := #(#SDL_TrayEntry #*).
	firstKeywordSubstringsToRemove := #('TrayEntry').
	targetClass := self class environment classNamed: #SDL3TrayEntry.
	theWord := 'entry'.
	excludedSelectors := #().
	explicitRenames := {
		} asOrderedDictionary
]
