Class {
	#name : 'CIGSDL3WindowScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing',
	#package : 'CIG-SDL3PostProcessing'
}

{ #category : 'initialization' }
CIGSDL3WindowScripts >> initializeParameters [

	targetArgument := #(#SDL_Window #*).
	suffix := 'Window:'.
	targetClass := self class environment classNamed: #SDL3Window.
	theWord := 'window'.
	excludedSelectors := #().
	explicitRenames := {
		'textInputActive' -> 'isTextInputActive'.
		'displayFor' -> 'display'.
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
		} asOrderedDictionary
]
