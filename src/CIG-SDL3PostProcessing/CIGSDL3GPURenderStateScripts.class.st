Class {
	#name : 'CIGSDL3GPURenderStateScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3GPURenderStateScripts >> initializeParameters [

	targetArgument := #(SDL_GPURenderState*).
	possibleSelectorSubstrings := #('GPURenderState:').
	targetClass := self class environment classNamed: #SDL3GPURenderState.
	theWord := 'state'.
	excludedSelectors := #().
	explicitRenames := {} asOrderedDictionary
]
