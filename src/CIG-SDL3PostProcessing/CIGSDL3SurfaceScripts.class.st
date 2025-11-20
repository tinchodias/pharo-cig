Class {
	#name : 'CIGSDL3SurfaceScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing',
	#package : 'CIG-SDL3PostProcessing'
}

{ #category : 'initialization' }
CIGSDL3SurfaceScripts >> initializeParameters [

	targetArgument := #(#SDL_Surface #*).
	suffix := 'Surface:'.
	targetClass := self class environment classNamed: #SDL3Surface.
	theWord := 'surface'.
	excludedSelectors :=  #(flipSurface:flip:).
	explicitRenames := { 
		'flipSurface:Flip:' -> 'flip:'.
		'rLEEnabled:' -> 'isRLEEnabled:'.
		'convertAndColorspaceFormat:palette:colorspace:props:' -> 'copyWithFormat:palette:colorspace:props:'.
		'convertFormat:' -> 'copyWithFormat:'
		} asOrderedDictionary
]
