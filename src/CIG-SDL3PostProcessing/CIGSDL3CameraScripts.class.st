Class {
	#name : 'CIGSDL3CameraScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3CameraScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	targetArgument := #(#SDL_Camera #*).
	firstKeywordSubstringsToRemove := #().
	targetClass := self class environment classNamed: #SDL3Camera.
	theWord := 'camera'.
	excludedSelectors := #().
	explicitRenames := {
		#iD -> #id.
		#properties -> #propertiesID.
		} asOrderedDictionary
]
