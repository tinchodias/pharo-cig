Class {
	#name : 'CIGSDL3GPUComputePassScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3GPUComputePassScripts >> initializeParameters [
	"
	self new generateForwardingAPI
	"

	targetArgument := #(SDL_GPUComputePass*).
	firstKeywordSubstringsToRemove := #('GPUComputePass' 'ComputePass').
	targetClass := self class environment classNamed: #SDL3GPUComputePass.
	theWord := 'compute_pass'.
	excludedSelectors := #().
	explicitRenames := {
		#dispatchGPUComputeGroupcountX:groupcountY:groupcountZ: -> #dispatchWorkgroupCountX:y:z:
		} asOrderedDictionary
]
