Class {
	#name : 'CIGSDL3DisplayScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3-Own-ForwardingAPI',
	#package : 'CIG-SDL3-Own',
	#tag : 'ForwardingAPI'
}

{ #category : 'converting' }
CIGSDL3DisplayScripts >> forwardingMethodCategory [

	^ #accessing
]

{ #category : 'converting' }
CIGSDL3DisplayScripts >> forwardingMethodMessageSendFor: each [

	^ String streamContents: [ :stream |
		each key selector keywords with: ({ 'id' }, each key argumentNames allButFirst)
			do: [ :a :b | stream << a; space; << b; space ] ]
]

{ #category : 'initialization' }
CIGSDL3DisplayScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	"This API was a bit problematic due to DisplayMode"

	targetArgument := #(#SDL_DisplayID).
	firstKeywordSubstringsToRemove := #(DisplayID).
	targetClass := self class environment classNamed: #SDL3Display.
	theWord := 'displayID'.
	excludedSelectors := #(
		#'getDisplayBoundsDisplayID:rect:'
		#'getDisplayUsableBoundsDisplayID:rect:'
		#'getFullscreenDisplayModesDisplayID:count:').
	explicitRenames := {
		#displayContentScale -> #contentScale.
		#displayName -> #name.
		#displayProperties -> #propertiesID.
		} asOrderedDictionary
]
