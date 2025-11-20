Class {
	#name : 'CIGSDL3RendererScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing',
	#package : 'CIG-SDL3PostProcessing'
}

{ #category : 'initialization' }
CIGSDL3RendererScripts >> initializeParameters [

	targetArgument := #(#SDL_Renderer #*).
	suffix := 'Renderer:'.
	targetClass := self class environment classNamed: #SDL3Renderer.
	theWord := 'renderer'.
	excludedSelectors := #().
"	excludedSelectors := #(renderCoord renderFill renderGeom renderLine renderPoint renderRect renderTexture renderDebugText)."
	explicitRenames := {
	 	'renderViewportSet' -> 'isRenderViewportSet'.
		'renderClipEnabled' -> 'isRenderClipEnabled'.
		'newTextureWithPropertiesProps:' -> 'newTextureWithProperties:'.
		'renderCoordinatesFromWindowX:windowY:x:y:' -> 'convertRenderCoordinatesFromWindowX:windowY:intoX:y:'.
		'renderCoordinatesToWindowX:y:windowX:windowY:' -> 'convertRenderCoordinatesToWindowX:y:intoWindowX:windowY:'.
		'getRenderScaleIntoX:scaleY:' -> 'getScaleIntoX:y:'
		} asOrderedDictionary 
]
