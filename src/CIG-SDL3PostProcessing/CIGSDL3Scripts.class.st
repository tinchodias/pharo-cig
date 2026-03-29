Class {
	#name : 'CIGSDL3Scripts',
	#superclass : 'Object',
	#instVars : [
		'targetArgument',
		'targetClass',
		'explicitRenames',
		'theWord',
		'excludedSelectors',
		'ffiCallMethods',
		'methodsAndForwardingSelectors',
		'firstKeywordSubstringsToRemove'
	],
	#category : 'CIG-SDL3PostProcessing-ForwardingAPI',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'ForwardingAPI'
}

{ #category : 'converting' }
CIGSDL3Scripts class >> generateForwardingAPI [
	<script>
	
	self subclassesDo: [ :each | each new generateForwardingAPI ]
]

{ #category : 'converting' }
CIGSDL3Scripts class >> stdoutMarkdownTables [
	<script>
	
	self subclassesDo: [ :each |
		Stdio stdout
			<< each name; lf;
			<< each new asMarkdownTable; lf ]
]

{ #category : 'converting' }
CIGSDL3Scripts >> asMarkdownTable [

	^ String streamContents: [ :writeStream |
		methodsAndForwardingSelectors asOrderedDictionary keysAndValuesDo: [ :key :value |
			writeStream << '| `'.
			writeStream << key selector.
			writeStream << '` | `#'.
			writeStream << value.
			writeStream << '` |'; lf.
		 ].
		]
]

{ #category : 'private' }
CIGSDL3Scripts >> camelCasedWordsOf: aString [ 

	| words word |
	words := OrderedCollection new.
	word := ''.

	aString do: [ :char |
		(char isUppercase and: [ word notEmpty and: [ word last isUppercase not ] ])
			ifTrue: [
				"End current word and start a new one"
				| index |
				index := word detectIndex: [ :e | e isLowercase ] ifNone: [ 2 ].
				index <= 2
					ifTrue: [
						"Most common case: first or second char is lowercase"
						words add: word ]
					ifFalse: [
						"Special case: word begins with an ACRONYM, and we split it in a separate word"
						words
							add: (word first: index - 2);
							add: (word allButFirst: index - 2) ].
				word := char asString ]
			ifFalse: [
				"Accumulate in current word"
				word := word copyWith: char ] ].

	"End last word"
	word isEmpty ifFalse: [ words add: word ].
	
"	aString splitCamelCase."
	^ words
]

{ #category : 'hooks' }
CIGSDL3Scripts >> explicitPrefixRenames [

	^ {
		'gPU' -> 'gpu'
		} asOrderedDictionary 
]

{ #category : 'converting' }
CIGSDL3Scripts >> forwardingMethodCategory [

	^ #'*SDL3-API'
]

{ #category : 'converting' }
CIGSDL3Scripts >> forwardingMethodHeaderFor: each [

	^ each key numArgs = 1
		ifTrue: [ each value ]
		ifFalse: [
			String streamContents: [ :stream |
				each value keywords with: each key argumentNames allButFirst
					do: [ :a :b | stream << a; space; << b; space ] ] ]
]

{ #category : 'converting' }
CIGSDL3Scripts >> forwardingMethodMessageSendFor: each [

	^ String streamContents: [ :stream |
		each key selector keywords with: ({ 'self' }, each key argumentNames allButFirst)
			do: [ :a :b | stream << a; space; << b; space ] ]
]

{ #category : 'initialization' }
CIGSDL3Scripts >> forwardingSelectorFor: method [
	
	| keywords newSelector |
"	(method selector = #getGPUDeviceProperties:) ifTrue: [ 1halt ]."

	keywords := self phase1: method.
	newSelector := self phase2: keywords.
	newSelector := self phase3: newSelector.

"	newSelector = #gpuProperties ifTrue: [ 1halt ]."


	^ newSelector
]

{ #category : 'converting' }
CIGSDL3Scripts >> generateForwardingAPI [
	" == Generate forwarding API == "

	methodsAndForwardingSelectors do: [ :each |
		| sourceCode |
"		self
			assert: [ each key argumentNames first = theWord ]
			description: 'In SDL3 we can do this assumption on first argument'."
"		each key argumentNames first = theWord ifFalse: [ {self. each} inspect ]."

		sourceCode := '{1}
			
			^ self ffiLibrary {2}' format: {
			self forwardingMethodHeaderFor: each.
			self forwardingMethodMessageSendFor: each.
			}.
		(targetClass >> (targetClass compile: sourceCode classified: self forwardingMethodCategory)) reformat ]
]

{ #category : 'initialization' }
CIGSDL3Scripts >> initialize [

	super initialize.

	self
		initializeParameters;
		initializeCandidateAPI;
		initializeForwardingSelectors
]

{ #category : 'initialization' }
CIGSDL3Scripts >> initializeCandidateAPI [

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
CIGSDL3Scripts >> initializeForwardingSelectors [

	methodsAndForwardingSelectors := ffiCallMethods
		collect: [ :method | method -> (self forwardingSelectorFor: method) ].

	"If not empty, probably the remaining requires a manual update"
	explicitRenames ifNotEmpty: [
		explicitRenames inspectWithLabel: 'Remaining renames in ', self className ]
]

{ #category : 'initialization' }
CIGSDL3Scripts >> initializeParameters [

	self subclassResponsibility
]

{ #category : 'private' }
CIGSDL3Scripts >> phase1: method [

	| keywords newFirstKeyword wordsInFirstKeyword |
	keywords := method selector keywords.

	"We assume first argument is my entity, e.g. renderer, 
	but CIG doesn't explicit it in the keyword when it is the only argument."
	"A priori, just remove colons"
	newFirstKeyword := keywords first allButLast: 1.
	firstKeywordSubstringsToRemove do: [ :substr |
		newFirstKeyword := newFirstKeyword copyReplaceAll: substr with: '' ].

	"Prepare to do renames based on selector's first word"
	wordsInFirstKeyword := self camelCasedWordsOf: newFirstKeyword.

	" -- Only keep my entity name in certain cases -- "
	(excludedSelectors noneSatisfy: [ :each | method selector beginsWith: each ]) ifTrue: [ 
		| firstArgument |
		wordsInFirstKeyword removeAllSuchThat: [ :word | word asLowercase = theWord ].
		newFirstKeyword := ('' join: wordsInFirstKeyword) uncapitalized.
		(keywords size > 1 and: [
			firstArgument := keywords second withoutSuffix: ':'.
			(newFirstKeyword asLowercase endsWith: firstArgument asLowercase) ]) ifTrue: [
				newFirstKeyword := newFirstKeyword allButLast: firstArgument size ].
		keywords := { newFirstKeyword }, keywords allButFirst ].

	" -- get* -- "
	wordsInFirstKeyword first = 'get' ifTrue: [
		| tail |
		newFirstKeyword := keywords size = 1
			ifTrue: [ '' join: { wordsInFirstKeyword second uncapitalized }, (wordsInFirstKeyword allButFirst: 2) ]
			ifFalse: [ '' join: (wordsInFirstKeyword, #('Into')) ].
		tail := (keywords size > 1 and: [
				keywords second asLowercase beginsWith: wordsInFirstKeyword last asLowercase ]) 
			ifFalse: [ keywords allButFirst ]
			ifTrue: [
				"Tackle an annoying word repetition"
				{ keywords second allButFirst: wordsInFirstKeyword last size }, (keywords allButFirst: 2) ].
		keywords := { newFirstKeyword }, tail ].

	" -- *set* -- "
	wordsInFirstKeyword first = 'set' ifTrue: [
		newFirstKeyword := '' join: ({ wordsInFirstKeyword second uncapitalized }, (wordsInFirstKeyword allButFirst: 2)).
		keywords := { newFirstKeyword }, keywords allButFirst ].

	
	^ keywords
]

{ #category : 'private' }
CIGSDL3Scripts >> phase2: input [

	| keywords newFirstKeyword wordsInFirstKeyword |
	keywords := input.

	newFirstKeyword := keywords first.
	wordsInFirstKeyword := self camelCasedWordsOf: newFirstKeyword.

	"May merge first and second keywords"
	keywords :=
		keywords size = 1
			ifTrue: [ { newFirstKeyword } ]
			ifFalse: [
				"Tackle an annoying word repetition"
				(keywords second beginsWith: wordsInFirstKeyword last asLowercase)
					ifTrue: [
						newFirstKeyword asLowercase = wordsInFirstKeyword last asLowercase
							ifTrue: [ { keywords second uncapitalized }, keywords allButFirst: 2 ]
							ifFalse: [
								{ newFirstKeyword allButLast: wordsInFirstKeyword last size. keywords second capitalized }, (keywords allButFirst: 2) ] ]
					ifFalse: [
						{ newFirstKeyword, keywords second capitalized }, (keywords allButFirst: 2) ] ].
	
	^ '' join: keywords
]

{ #category : 'initialization' }
CIGSDL3Scripts >> phase3: input [

	| newSelector |
	newSelector := input.
	
	"More generic"
	self explicitPrefixRenames keysAndValuesDo: [ :eachPrefix :eachReplacement |
		(newSelector beginsWith: eachPrefix) ifTrue: [
			newSelector := eachReplacement, (newSelector allButFirst: eachPrefix size) ] ].

	"Explicit renames"
	explicitRenames
		at: newSelector
		ifPresent: [ :value |
			explicitRenames removeKey: newSelector.
			newSelector := value ].

	^ newSelector
]
