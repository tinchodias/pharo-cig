Class {
	#name : 'CIGSDL3SensorScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3SensorScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	targetArgument := #(#SDL_Sensor #*).
	firstKeywordSubstringsToRemove := #().
	targetClass := self class environment classNamed: #SDL3Sensor.
	theWord := 'sensor'.
	excludedSelectors := #().
	explicitRenames := {
		#iD -> #id.
		#properties -> #propertiesID.
		} asOrderedDictionary
]
