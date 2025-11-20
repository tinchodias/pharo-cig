Class {
	#name : 'CIGSDL3GPUShaderScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing',
	#package : 'CIG-SDL3PostProcessing'
}

{ #category : 'initialization' }
CIGSDL3GPUShaderScripts >> initializeParameters [

	targetArgument := #(SDL_GPUShader*).
	suffix := 'GPUShader:'.
	targetClass := self class environment classNamed: #SDL3GPUShader.
	theWord := 'shader'.
	excludedSelectors := #().
	explicitRenames := {} asOrderedDictionary
]
