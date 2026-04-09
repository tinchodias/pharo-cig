Class {
	#name : 'CIGSDL3WindowScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3WindowScripts >> initializeParameters [

	targetArgument := #(#SDL_Window #*).
	firstKeywordSubstringsToRemove := #('Window').
	targetClass := self class environment classNamed: #SDL3Window.
	theWord := 'window'.
	excludedSelectors := #().
	explicitRenames := {
		'textInputActive' -> 'isTextInputActive'.
		'displayFor' -> 'displayID'.
		'iD' -> 'id'.
		'fullscreenMode' -> 'isFullscreenMode'.
		'keyboardGrab' -> 'isKeyboardGrabbed'.
		'mouseGrab' -> 'isMouseGrabbed'.
		'flashOperation:' -> 'flashWithOperation:'.
		'relativeMouseMode' -> 'isRelativeMouseMode'.
		'eglGetSurface' -> 'eglSurface'.
		'glCreateContext' -> 'glNewContext'.
		'screenKeyboardShown' -> 'isScreenKeyboardShown'.
		'newRendererName:' -> 'newRendererFor:'.
		'fillDocumentFill:' -> 'fillDocumentSpace:'
		} asOrderedDictionary
]
