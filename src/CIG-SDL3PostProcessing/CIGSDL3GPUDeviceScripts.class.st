Class {
	#name : 'CIGSDL3GPUDeviceScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3GPUDeviceScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	targetArgument := #(SDL_GPUDevice*).
	firstKeywordSubstringsToRemove := #('GPUDevice' 'Device').
	targetClass := self class environment classNamed: #SDL3GPUDevice.
	theWord := 'device'.
	excludedSelectors := #().
	explicitRenames := {
		#claimWindowForWindow: -> #claimWindow:.
		#releaseWindowFromWindow: -> #releaseWindow:
		} asOrderedDictionary
]
