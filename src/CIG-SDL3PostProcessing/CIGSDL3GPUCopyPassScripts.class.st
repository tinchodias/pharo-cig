Class {
	#name : 'CIGSDL3GPUCopyPassScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3GPUCopyPassScripts >> initializeParameters [
	"
	self new generateForwardingAPI
	"

	targetArgument := #(SDL_GPUCopyPass*).
	possibleSelectorSubstrings := #('GPUCopyPass:' 'CopyPass:').
	targetClass := self class environment classNamed: #SDL3GPUCopyPass.
	theWord := 'copy_pass'.
	excludedSelectors := #().
	explicitRenames := {} asOrderedDictionary
]
