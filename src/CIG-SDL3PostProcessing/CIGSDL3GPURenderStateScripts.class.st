Class {
	#name : 'CIGSDL3GPURenderStateScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing',
	#package : 'CIG-SDL3PostProcessing'
}

{ #category : 'initialization' }
CIGSDL3GPURenderStateScripts >> initializeParameters [

	targetArgument := #(SDL_GPURenderState*).
	suffix := 'GPURenderState:'.
	targetClass := self class environment classNamed: #SDL3GPURenderState.
	theWord := 'state'.
	excludedSelectors := #().
	explicitRenames := {} asOrderedDictionary
]
