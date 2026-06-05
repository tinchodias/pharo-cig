Class {
	#name : 'CIGSDL3TextureScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3TextureScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	targetArgument := #(#SDL_Texture #*).
	firstKeywordSubstringsToRemove := #('Texture').
	targetClass := self class environment classNamed: #SDL3Texture.
	theWord := 'texture'.
	excludedSelectors := #().
	explicitRenames := {
		'rendererFrom' -> 'renderer'.
		'scaleModeScaleMode:' -> 'scaleMode:'.
		#properties -> #propertiesID.
		} asOrderedDictionary
]
