Class {
	#name : 'CigNameGenerator',
	#superclass : 'CigVisitor',
	#instVars : [
		'withCamelCase',
		'withPrefixInFunctionName'
	],
	#category : 'CIG-Base',
	#package : 'CIG',
	#tag : 'Base'
}

{ #category : 'private' }
CigNameGenerator >> applyCamelCaseTo: aString [

	self isCamelCase ifFalse: [ ^ aString ].
	
	^ String streamContents: [ :stream | 
		(aString substrings: '_') 
			do: [ :each | stream << each capitalized ] ]
]

{ #category : 'private' }
CigNameGenerator >> applyFunctionModifiersTo: aString in: anElement [
	| result |

	result := aString.
	self isPrefixInFunctionName ifFalse: [ 
		result := self 
			applyPrefixInFunctionName: result
			in: anElement ].

	^ result
]

{ #category : 'private' }
CigNameGenerator >> applyPrefixInFunctionName: aString in: anElement [
	| prefix result |
	
	prefix := anElement root prefix.
	(aString asLowercase beginsWith: prefix asLowercase) ifFalse: [ ^ aString ].
	
	result := aString allButFirst: prefix size.
	[ result first = $_ ] 
	whileTrue: [ result := result allButFirst ].
	
	^ result
]

{ #category : 'initialization' }
CigNameGenerator >> initialize [

	super initialize.
	self withCamelCase.
	self withPrefixInFunctionName
]

{ #category : 'testing' }
CigNameGenerator >> isCamelCase [

	^ withCamelCase
]

{ #category : 'testing' }
CigNameGenerator >> isPrefixInFunctionName [

	^ withPrefixInFunctionName
]

{ #category : 'visiting' }
CigNameGenerator >> visit: anElement [

	^ anElement acceptNameGenerator: self
]

{ #category : 'visiting' }
CigNameGenerator >> visitConstructor: anElement [
	| params |

	^ (String streamContents: [ :stream | 
			stream 
				<< anElement disambiguatedName uncapitalized 
				<< '_new'.
			(params := self parameters) size = 1
				ifTrue: [ 
					stream << ': ' << params first name  ]
				ifFalse: [  
					self parameters do: [ :each | 
						stream 
							<< each name  
							<< ': ' 
							<< each name 
							<< ' ' ] ] ])
		trimmed
]

{ #category : 'visiting' }
CigNameGenerator >> visitElement: anElement [
	| prefix name |

	prefix := anElement root prefix.
	name := self applyCamelCaseTo: anElement sanitizedName.
	^ String streamContents: [ :stream |
		(name asLowercase beginsWith: prefix asLowercase)
			ifFalse: [ stream << prefix capitalized ].
		stream << name ]
]

{ #category : 'visiting' }
CigNameGenerator >> visitFunction: anElement [

	^ (String streamContents: [ :stream | 
			stream  << (self 
				applyFunctionModifiersTo: anElement sanitizedName
				in: anElement).
			anElement buildParametersOn: stream ])
		trimmed
]

{ #category : 'visiting' }
CigNameGenerator >> visitMethod: anElement [

	^ (String streamContents: [ :stream | 
			stream  << anElement disambiguatedName uncapitalized.
			anElement buildParametersOn: stream ])
		trimmed
]

{ #category : 'visiting' }
CigNameGenerator >> visitNamespace: anElement [

	^ (self visitElement: anElement), 'Namespace'
]

{ #category : 'visiting' }
CigNameGenerator >> visitTypedef: anElement [

	"typedef will be generated as itself (no prefix, since is not a class)"
	^ anElement name
]

{ #category : 'accessing' }
CigNameGenerator >> withCamelCase [
	"Indicates the structures generated (struct, unions, enum, classes) will be translated to a 
	 camel case convention. e.g. My_struct_with_underscores will become MyStructWithUnderscores. 
	 DEFAULT: true (as it looks more according to our own conventions)"

	withCamelCase := true
]

{ #category : 'accessing' }
CigNameGenerator >> withPrefixInFunctionName [
	"Indicates if the function will keep a prefix equivallent to the library prefix in its name 
	 in case it has it. E.g. A function of an Xml library named xml_do_something() will have as 
	 name xml_do_something if this is true, do_something if false.
	 DEFAULT: true"

	withPrefixInFunctionName := true
]

{ #category : 'accessing' }
CigNameGenerator >> withoutCamelCase [

	withCamelCase := false
]

{ #category : 'accessing' }
CigNameGenerator >> withoutPrefixInFunctionName [

	withPrefixInFunctionName := false
]
