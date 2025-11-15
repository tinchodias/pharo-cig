Class {
	#name : 'CIGSDL3RendererScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing',
	#package : 'CIG-SDL3PostProcessing'
}

{ #category : 'initialization' }
CIGSDL3RendererScripts >> initializeParameters [

	targetArgument := #(#SDL_Renderer #* #renderer).
	suffix := 'Renderer:'.
	targetClass := self class environment classNamed: #SDL3Renderer.
	theWord := 'renderer'.
	excludedSelectors := #(renderCoord renderFill renderGeom renderLine renderPoint renderRect renderTexture renderDebugText).
	explicitRenames := {
	 	'viewportSet'. 'isViewportSet'.
		'clipEnabled'. 'isClipEnabled'.
		'rendererName'. 'name'.
		'rendererProperties'. 'properties'.
		'targetTexture:'. 'target:'.
		'viewportRect:'. 'viewport:'.
		'newTextureWithPropertiesProps:'. 'newTextureWithProperties:'.
		'renderCoordinatesFromWindowX:windowY:x:y:'. 'convertRenderCoordinatesFromWindowX:windowY:intoX:y:'.
		'renderCoordinatesToWindowX:y:windowX:windowY:'. 'convertRenderCoordinatesToWindowX:y:intoWindowX:windowY:'.
		'drawBlendModeBlendMode:'. 'blendMode:'.
		'drawColorFloatR:g:b:a:'. 'colorFloatR:g:b:a:'.
		'drawColorR:g:b:a:'. 'colorR:g:b:a:'.
		'getScaleIntoX:scaleY:'. 'getScaleIntoX:y:'
		}
]
