Class {
	#name : 'CIGSDL3IOStreamScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'initialization' }
CIGSDL3IOStreamScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	targetArgument := #(#SDL_IOStream #*).
	firstKeywordSubstringsToRemove := #(IOContext IOSrc DstValue SrcValue Src Dst).
	targetClass := self class environment classNamed: #SDL3IOStream.
	theWord := 'context'.
	excludedSelectors := #().
	explicitRenames := {
		#iOProperties -> #ioProperties.
		#iOSize -> #ioSize.
		#iOStatus -> #ioStatus.
		} asOrderedDictionary
]
