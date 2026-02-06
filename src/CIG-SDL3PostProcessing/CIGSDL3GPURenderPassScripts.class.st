Class {
	#name : 'CIGSDL3GPURenderPassScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3GPURenderPassScripts >> initializeParameters [
	"
	self new generateForwardingAPI
	"

	targetArgument := #(SDL_GPURenderPass*).
	possibleSelectorSubstrings := #('GPURenderPass:' 'RenderPass:').
	targetClass := self class environment classNamed: #SDL3GPURenderPass.
	theWord := 'render_pass'.
	excludedSelectors := #().
	explicitRenames := {
		'gpuScissorScissor:' -> 'scissor:'.
		'gpuViewportViewport:' -> 'viewport:'.
		'gpuBlendConstantsBlendConstants:' -> 'blendConstants:'.
		'gpuStencilReference:' -> 'stencilReference:'.
		} asOrderedDictionary
]
