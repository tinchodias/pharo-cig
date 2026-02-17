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
	firstKeywordSubstringsToRemove := #('TrayMenu' 'Tray').
	targetClass := self class environment classNamed: #SDL3TrayMenu.
	theWord := 'menu'.
	excludedSelectors := #().
	explicitRenames := {
		#insertEntryAtPos:label:flags: -> #insertEntryAt:label:flags:.
		#parent -> #parentTray.
		} asOrderedDictionary
]
