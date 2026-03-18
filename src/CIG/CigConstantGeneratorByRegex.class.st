Class {
	#name : 'CigConstantGeneratorByRegex',
	#superclass : 'CigConstantGeneratorGroupStrategy',
	#instVars : [
		'defaultSuffix',
		'regexDictionary'
	],
	#category : 'CIG-Constant',
	#package : 'CIG',
	#tag : 'Constant'
}

{ #category : 'generating' }
CigConstantGeneratorByRegex >> addConstants: aCollectionOfMacroDefinitions to: aConstantClass [
	
	self error: 'Should not arrive here'
]

{ #category : 'generating' }
CigConstantGeneratorByRegex >> addConstants: aCollectionOfMacroDefinitions to: aConstantClass in: aLibraryGenerator [
	| groups classes cachedAssociations |

	cachedAssociations := regexDictionary associations collect: [ :assoc |
		assoc key asRegex -> assoc value ].

	groups := aCollectionOfMacroDefinitions groupedBy: [ :each | 
		cachedAssociations
			detect: [ :assoc | assoc key matches: each name ]
			ifFound: [ :assoc | 
"				(aLibraryGenerator nameGenerator
					applyFunctionModifiersTo: (assoc key matchesIn: each name)
					in: each) asCamelcasedUnderscores"
				assoc value value "second #value allows e.g. a BlocClosure" ]
			ifNone: [ defaultSuffix ] ].

	classes := Set new.
	groups keysAndValuesDo: [ :aSuffix :aCollection | 
		| groupClass className |
	
		className := (aConstantClass name withoutSuffix: 'Constants'), aSuffix, 'Constants'.
		groupClass := CigConstantGeneratorNoGroupStrategy new 
			configureWith: self;
			addConstants: aCollection 
			to: ((SharedPool << className asSymbol)
				tag: aConstantClass packageTagName;
				package: aConstantClass packageName;
				install)
			in: aLibraryGenerator.
	
		classes add: groupClass ].
		
	^ self 
		updateClass: aConstantClass 
		with: [ :aBuilder |
			aBuilder sharedPools: (classes collect: #name as: Array) sorted ]
]

{ #category : 'accessing' }
CigConstantGeneratorByRegex >> defaultSuffix: aString [

	defaultSuffix := aString
]

{ #category : 'accessing' }
CigConstantGeneratorByRegex >> regexDictionary: aRegexDictionary [

	regexDictionary := aRegexDictionary
]
