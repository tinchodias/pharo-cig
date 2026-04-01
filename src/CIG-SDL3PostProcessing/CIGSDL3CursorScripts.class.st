Class {
	#name : 'CIGSDL3CursorScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3CursorScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	targetArgument := #(#SDL_Cursor #*).
	firstKeywordSubstringsToRemove := #().
	targetClass := self class environment classNamed: #SDL3Cursor.
	theWord := 'cursor'.
	excludedSelectors := #().
	explicitRenames := {
		#set -> #setActive.
		} asOrderedDictionary
]
