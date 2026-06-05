Class {
	#name : 'CIGSDL3RendererScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3RendererScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	targetArgument := #(#SDL_Renderer #*).
	firstKeywordSubstringsToRemove := #('Renderer').
	targetClass := self class environment classNamed: #SDL3Renderer.
	theWord := 'renderer'.
	excludedSelectors := #().
	explicitRenames := {
	 	'renderViewportSet' -> 'isRenderViewportSet'.
		'renderClipEnabled' -> 'isRenderClipEnabled'.
		'newTextureWithPropertiesProps:' -> 'newTextureWithProperties:'.
		'renderCoordinatesFromWindowX:windowY:x:y:' -> 'convertRenderCoordinatesFromWindowX:windowY:intoX:y:'.
		'renderCoordinatesToWindowX:y:windowX:windowY:' -> 'convertRenderCoordinatesToWindowX:y:intoWindowX:windowY:'.
		'getRenderScaleIntoX:scaleY:' -> 'getScaleIntoX:y:'.
		#renderDrawBlendModeBlendMode: -> #renderDrawBlendMode:.
		#properties -> #propertiesID.
		} asOrderedDictionary 
]
