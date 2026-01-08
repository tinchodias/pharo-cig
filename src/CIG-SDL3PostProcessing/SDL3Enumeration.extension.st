Extension { #name : 'SDL3Enumeration' }

{ #category : '*CIG-SDL3PostProcessing' }
SDL3Enumeration class >> enumDeclCommonPrefix [

	| shortestName names |
	names := self enumDecl
		pairsCollect: [ :eachName :eachValue | eachName ].

	shortestName := names detectMin: [ :each | each size ].

	shortestName withIndexDo: [ :char :i |
		(names allSatisfy: [ :each | (each at: i) = char ])
			ifFalse: [ ^ shortestName first: i - 1 ] ].

	^ shortestName
]

{ #category : '*CIG-SDL3PostProcessing' }
SDL3Enumeration class >> enumDeclToCamelCaseAt: aName prefix: prefix [

	| newName |
	newName := aName withoutPrefix: prefix.
	newName := String streamContents: [ :stringStream |
		($_ split: newName) do: [ :each |
			stringStream << each asLowercase asCamelCase ] ].
	newName := newName uncapitalized.

	newName isValidSelector ifFalse: [
		newName :=
			self
				enumDeclToCamelCaseAt: aName
				prefix: prefix
				givenInvalidName: newName ].
	
	^ newName
]

{ #category : '*CIG-SDL3PostProcessing' }
SDL3Enumeration class >> enumDeclToCamelCaseAt: aName prefix: prefix givenInvalidName: invalidName [

	invalidName first isDigit ifFalse: [ self error ].

	^ 'at', invalidName
]

{ #category : '*CIG-SDL3PostProcessing' }
SDL3Enumeration class >> enumDeclToCamelCaseDictionary [

	| prefix result |
	"Must take another approach if there is only one pair"
	self assert: [ self enumDecl size > 2 ].

	prefix := self enumDeclCommonPrefix.
	result := OrderedDictionary new.

	self enumDecl pairsDo: [ :aName :aValue |
		result
			at: aName
			put: (self enumDeclToCamelCaseAt: aName prefix: prefix) ].

	^ result
]
