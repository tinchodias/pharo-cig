Class {
	#name : 'CIGSDL3TextureScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing',
	#package : 'CIG-SDL3PostProcessing'
}

{ #category : 'initialization' }
CIGSDL3TextureScripts >> initializeParameters [

	targetArgument := #(#SDL_Texture #* #texture).
	suffix := 'Texture:'.
	targetClass := self class environment classNamed: #SDL3Texture.
	theWord := 'texture'.
	excludedSelectors := #().
	explicitRenames := {
		'rendererFrom'. 'renderer'.
		'scaleModeScaleMode:'. 'scaleMode:' }
]
