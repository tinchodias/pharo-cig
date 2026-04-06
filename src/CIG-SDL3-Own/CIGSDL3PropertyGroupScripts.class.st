Class {
	#name : 'CIGSDL3PropertyGroupScripts',
	#superclass : 'CIGSDL3Scripts',
	#category : 'CIG-SDL3-Own-ForwardingAPI',
	#package : 'CIG-SDL3-Own',
	#tag : 'ForwardingAPI'
}

{ #category : 'converting' }
CIGSDL3PropertyGroupScripts >> forwardingMethodCategory [

	^ #accessing
]

{ #category : 'converting' }
CIGSDL3PropertyGroupScripts >> forwardingMethodMessageSendFor: each [

	^ String streamContents: [ :stream |
		each key selector keywords with: ({ 'id' }, each key argumentNames allButFirst)
			do: [ :a :b | stream << a; space; << b; space ] ]
]

{ #category : 'initialization' }
CIGSDL3PropertyGroupScripts >> initializeParameters [
	<script: 'self new generateForwardingAPI'>

	"SDL3 only has PropertiesID, an uint, so SDL3PropertyGroup is created manually.
	Note --> Check #phase1: workaround
	"

	targetArgument := #(#SDL_PropertiesID).
	firstKeywordSubstringsToRemove := #(Property WithProperties Properties).
	targetClass := self class environment classNamed: #SDL3PropertyGroup.
	theWord := 'props'.
	excludedSelectors := #().
	explicitRenames := {
		#gpuSupports -> #doesGPUSupportProperties.
		#copySrcDst: -> #copyTo:.
		#clearAt: -> #removeKey:.
		#hasAt: -> #includesKey: } asOrderedDictionary
]

{ #category : 'private' }
CIGSDL3PropertyGroupScripts >> phase1: method [

	| regexRules |
	regexRules := {
		'defaultValue' -> 'ifAbsent'.
		'value' -> 'put'.
		'name' -> 'At'.
		'get' -> ''. 'Into' -> ''. "ugly: super introduces get*Into pattern and we revert it here"
		}.
	^ (super phase1: method) collect: [ :each |
		regexRules
			inject: each
			into: [ :result :eachRule |
				result  copyWithRegex: eachRule key matchesReplacedWith: eachRule value ] ]

]
