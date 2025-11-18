Class {
	#name : 'CIGSDL3Scripts',
	#superclass : 'Object',
	#instVars : [
		'targetArgument',
		'suffix',
		'targetClass',
		'explicitRenames',
		'renames',
		'theWord',
		'excludedSelectors',
		'ffiCallMethods'
	],
	#category : 'CIG-SDL3PostProcessing',
	#package : 'CIG-SDL3PostProcessing'
}

{ #category : 'converting' }
CIGSDL3Scripts class >> generateForwardingAPI [
	<script>
	
	self subclassesDo: [ :each | each new generateForwardingAPI ]
]

{ #category : 'converting' }
CIGSDL3Scripts >> asMarkdownTable [

	^ String streamContents: [ :writeStream |
		renames asOrderedDictionary keysAndValuesDo: [ :key :value |
			writeStream << '| `'.
			writeStream << key selector.
			writeStream << '` | `#'.
			writeStream << value.
			writeStream << '` |'; lf.
		 ].
		]
]

{ #category : 'converting' }
CIGSDL3Scripts >> generateForwardingAPI [
	" == Generate forwarding API == "

	| forwardingAPI header messageSend |

	forwardingAPI := renames collect: [ :each |
		self
			assert: [ each key argumentNames first = targetArgument last ]
			description: 'In SDL3 we can do this assumption on first argument'.

		header := each key numArgs = 1
			ifTrue: [ each value ]
			ifFalse: [
				String streamContents: [ :stream |
					each value keywords with: each key argumentNames allButFirst
						do: [ :a :b | stream << a; space; << b; space ] ] ].

		messageSend := String streamContents: [ :stream |
			each key selector keywords with: ({ 'self' }, each key argumentNames allButFirst)
				do: [ :a :b | stream << a; space; << b; space ] ].
		'{1}
			
			^ self ffiLibrary {2}' format: {
			header.
			messageSend
			} ].

	forwardingAPI do: [ :each |
		(targetClass >> (targetClass compile: each classified: #API)) reformat ]
]

{ #category : 'initialization' }
CIGSDL3Scripts >> initialize [

	super initialize.

	self
		initializeParameters;
		initializeFFICallMethods;
		initializeRenames
]

{ #category : 'initialization' }
CIGSDL3Scripts >> initializeFFICallMethods [

	"The methods that belong to the renderer have a renderer as first argument. This is a convention in SDL3."
	ffiCallMethods := (LibSDL3 methods
		select: [ :method |
			(method literals anySatisfy: [ :each |
				each isSymbol and: [ each beginsWith: 'ffiCall' ] ]) ])
		select: [ :method |
			| literals signature parameters |
			literals := method literals.
			self assert: (literals count: [ :each | each isArray ]) = 1.
			signature := literals detect: [ :each | each isArray ].

			self assert: (signature count: [ :each | each isArray ]) = 1.
			parameters := signature detect: [ :each | each isArray ].
			parameters size >= targetArgument size and: [
				(parameters first: targetArgument size) = targetArgument ] ].

	ffiCallMethods sort: [ :a :b | a selector < b selector ]
]

{ #category : 'initialization' }
CIGSDL3Scripts >> initializeParameters [

	self subclassResponsibility
]

{ #category : 'initialization' }
CIGSDL3Scripts >> initializeRenames [

	renames := ffiCallMethods collect: [ :method |
		| keywords newFirstKeyword newKeywords words signature newSelector |
		signature := method literals detect: [ :each | each isArray ].
		keywords := method selector keywords.

		"We assume first argument is the renderer, but CIG doesn't explicit it in
		the keyword when it is the only argument"
		newFirstKeyword := (keywords first endsWith: suffix)
			ifTrue: [ (keywords first allButLast: suffix size) "remove whole suffix" ]
			ifFalse: [ keywords first allButLast: 1 "just remove colons" ].


		" == Phase 1 == "

		"Prepare to do renames based on selector's first word"
		words := OrderedCollection streamContents: [ :stream |
			| word |
			word := ''.
			newFirstKeyword do: [ :char |
				(char isUppercase and: [ word notEmpty and: [ word last isUppercase not ] ])
					ifTrue: [ stream nextPut: word. word := char asString ]
					ifFalse: [ word := word copyWith: char ] ].
			word isEmpty ifFalse: [ stream nextPut: word ] ].

		" -- Only keep *surface* in certain cases that are rendering operations -- "
		(excludedSelectors
			noneSatisfy: [ :each | method selector beginsWith: each ]) ifTrue: [ 
				words removeAllSuchThat: [ :word | word asLowercase = theWord ].
				newFirstKeyword := ('' join: words) uncapitalized.
				keywords := { newFirstKeyword }, keywords allButFirst ].

		" -- get* -- "
		words first = 'get' ifTrue: [
			| tail |
			newFirstKeyword := keywords size = 1
				ifTrue: [ '' join: { words second uncapitalized }, (words allButFirst: 2) ]
				ifFalse: [ '' join: (words, #('Into')) ].
			tail := (keywords size > 1 and: [
					keywords second asLowercase beginsWith: words last asLowercase ]) 
				ifFalse: [ keywords allButFirst ]
				ifTrue: [
					"Tackle an annoying word repetition"
					{ keywords second allButFirst: words last size }, (keywords allButFirst: 2) ].
			keywords := { newFirstKeyword }, tail ].

		" -- *set* -- "
		words first = 'set' ifTrue: [
	"	(words size > 1 and: [ (words first: 2) asArray = #('set' 'Render') ]) ifTrue: ["
			newFirstKeyword := '' join: ({ words second uncapitalized }, (words allButFirst: 2)).
			keywords := { newFirstKeyword }, keywords allButFirst ].



		" == Phase 2 == "

		"May merge first and second keywords"
		newKeywords := keywords size = 1
			ifTrue: [ { newFirstKeyword } ]
			ifFalse: [
				"Tackle an annoying word repetition"
				(keywords second beginsWith: words last asLowercase)
					ifTrue: [
						newFirstKeyword size = words last size
							ifTrue: [ { keywords second uncapitalized }, keywords allButFirst: 2 ]
							ifFalse: [
								{ newFirstKeyword allButLast: words last size. keywords second capitalized }, (keywords allButFirst: 2)] ]
					ifFalse: [ { newFirstKeyword, keywords second capitalized }, (keywords allButFirst: 2) ]
				].
		newSelector := '' join: newKeywords.


		" == Phase 3 == "

		"Explicit renames"
		explicitRenames
			at: newSelector
			ifPresent: [ :value |
				explicitRenames removeKey: newSelector.
				newSelector := value ].

		method -> newSelector ].
	
	explicitRenames ifNotEmpty: [ explicitRenames inspectWithLabel: 'Remaining renames in ', self className ]
]
