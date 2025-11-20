Class {
	#name : 'CIGSDL3GPUDeviceScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing',
	#package : 'CIG-SDL3PostProcessing'
}

{ #category : 'initialization' }
CIGSDL3GPUDeviceScripts >> initializeParameters [

	targetArgument := #(SDL_GPUDevice*).
	suffix := 'GPUDevice:'.
	targetClass := self class environment classNamed: #SDL3GPUDevice.
	theWord := 'device'.
	excludedSelectors := #().
	explicitRenames := {} asOrderedDictionary
]
