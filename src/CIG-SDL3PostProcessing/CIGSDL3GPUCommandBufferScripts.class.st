Class {
	#name : 'CIGSDL3GPUCommandBufferScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3GPUCommandBufferScripts >> initializeParameters [
	"
	self new generateForwardingAPI
	"

	targetArgument := #(SDL_GPUCommandBuffer*).
	firstKeywordSubstringsToRemove := #('GPUCommandBuffer' 'CommandBuffer').
	targetClass := self class environment classNamed: #SDL3GPUCommandBuffer.
	theWord := 'command_buffer'.
	excludedSelectors := #().
	explicitRenames := {
		'submitGPUCommandBufferAndAcquireFence' -> 'submitAndAcquireFence'.
		'waitAndAcquireGPUSwapchainTextureWindow:swapchainTexture:swapchainTextureWidth:swapchainTextureHeight:' -> 'waitAndAcquireGPUSwapchainTextureForWindow:into:width:height:'.
		#acquireGPUSwapchainTextureWindow:swapchainTexture:swapchainTextureWidth:swapchainTextureHeight: -> #acquireGPUSwapchainTextureForWindow:into:width:height:.
		} asOrderedDictionary
]
