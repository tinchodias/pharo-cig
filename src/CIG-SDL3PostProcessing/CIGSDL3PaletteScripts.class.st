Class {
	#name : 'CIGSDL3PaletteScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3PaletteScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	targetArgument := #(#SDL_Palette #*).
	firstKeywordSubstringsToRemove := #().
	targetClass := self class environment classNamed: #SDL3Palette.
	theWord := 'palette'.
	excludedSelectors := #().
	explicitRenames := {
		} asOrderedDictionary
]
