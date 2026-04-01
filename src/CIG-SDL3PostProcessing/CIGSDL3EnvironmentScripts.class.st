Class {
	#name : 'CIGSDL3EnvironmentScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3EnvironmentScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	targetArgument := #(#SDL_Environment #*).
	firstKeywordSubstringsToRemove := #(Environment).
	targetClass := self class environment classNamed: #SDL3Environment.
	theWord := 'environment'.
	excludedSelectors := #().
	explicitRenames := {
		} asOrderedDictionary
]
