Class {
	#name : 'CIGSDL3PostSteps',
	#superclass : 'Object',
	#category : 'CIG-SDL3PostProcessing-Core',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'Core'
}

{ #category : 'steps' }
CIGSDL3PostSteps class >> apply [

	self step1InitializeAndRebuild.
	self step2Enums.
	self step3Structs.
	self step4AddIntermediateEvents.
	self step5DeleteUnneededEventsAPI.
	self step6FixBool
]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step1InitializeAndRebuild [

	"Re-try struct initialization. The result should be empty:"
	Array streamContents: [ :stream |
		SDL3Structure allSubclassesDo: [ :each |
			[each rebuildFieldAccessors] onErrorDo: [
				stream nextPut: each ] ] ].

	"Alternative to S3Enumeration class >> initialize"
	SDL3Enumeration allSubclassesDo: #initializeEnumeration.
	SDL3Enumeration allSubclassesDo: #rebuildEnumAccessors.
	"Similar for union:"
	SDL3Union allSubclassesDo: #rebuildFieldAccessors
]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step2Enums [

	(SDL3Enumeration allSubclasses sorted: [:a :b | a name < b name])
		select: [ :enumClass |
			enumClass packageName = #SDL3 and: [
			enumClass classSide includesSelector: #enumDecl ] ]	
		thenDo: [ :enumClass |
			| renames env model allChanges |
			renames := enumClass enumDeclToCamelCaseDictionary.

			"Apply rename refactorings"

			env := RBPackageEnvironment packageNames: #('SDL3' "'SDL3-Own' 'SDL3-Tests' 'SDL3-Image'").
			env := env & (RBSelectorEnvironment new addMethod: (enumClass classSide >> #enumDecl); yourself) not.
			model := RBNamespace onEnvironment: env.

			allChanges := OrderedCollection new.
			renames keysAndValuesDo: [ :oldName :newName |
				allChanges addAll: (ReRenameMethodRefactoring new
			        model: model;
			        renameMethod: oldName
			        	in: enumClass classSide
						to: newName
						permutation: #();
			        renameChanges) changes ].

			allChanges := allChanges reject: [ :e |
				e class = RBAddMethodChange and: [
					"e protocol ~= #'accessing enum'"
					(e selector beginsWith: 'enumDecl') and: [ 
						e changeClassName = enumClass name ] ] ].
			
			allChanges do: #generateChanges ]
]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step3Structs [

	SDL3Structure allSubclasses do: [ :structClass |
		| renames env model allChanges |
		renames := OrderedDictionary new.
		structClass selectors
			select: [:selector | selector includes: $_ ]
			thenCollect: [ :selector |
				| newName |
				newName := String streamContents: [ :writeStream | | readStream |
					readStream := selector readStream.
					[ readStream atEnd ] whileFalse: [
						writeStream nextPutAll: (readStream upTo: $_) capitalized ] ].
				newName := newName uncapitalized.
				renames add: selector -> newName ].

		"Apply rename refactorings"
		env := RBPackageEnvironment packageNames: #('SDL3' "'SDL3-Own' 'SDL3-Tests' 'SDL3-Image'").
		model := RBNamespace onEnvironment: env.

		allChanges := OrderedCollection new.
		renames keysAndValuesDo: [ :oldName :newName |
			allChanges addAll: (ReRenameMethodRefactoring new
		        model: model;
		        renameMethod: oldName
		        	in: structClass
					to: newName
					permutation: (1 to: oldName numArgs);
		        renameChanges) changes ].

		allChanges := allChanges reject: [ :e |
			e class = RBAddMethodChange and: [
				(e changeClassName = #LibSDL3) or: [ 
				(e selector = #fieldsDesc) ] ] ].
		
		allChanges do: #generateChanges ]
]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step4AddIntermediateEvents [

	superclass :=
		(SDL3MappedEvent << #SDL3WindowIDEvent
			slots: {};
			tag: 'Own';
			package: 'SDL3') install.

	SDL3MappedEvent subclasses
		select: [ :each | each includesSelector: #windowID ]
		thenDo: [ :each | each superclass: superclass ].


	superclass :=
		(SDL3MappedEvent << #SDL3MouseEvent
			slots: {};
			tag: 'Own';
			package: 'SDL3') install.

	SDL3MappedEvent allSubclasses
		select: [ :each |
			(each name includesSubstring: 'Mouse')
			and: [ (each includesSelector: #which)
			and: [ (each includesSelector: #x) ] ] ]
		thenDo: [ :each | each superclass: superclass ]
]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step5DeleteUnneededEventsAPI [

	SDL3MappedEvent allSubclassesDo: [ :each | each removeSelector: #type ].

	(SDL3MappedEvent allSubclasses copyWithout: SDL3UserEvent) 
		do: [ :eachClass |
			(eachClass selectorsInProtocol: #'accessing - structure variables')
				select: [ :eachSelector | eachSelector last = $: ]
				thenDo: [ :eachSelector | eachClass removeSelector: eachSelector ] ].
]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step6FixBool [

	LibSDL3 compile: '_Bool '.
	(ReRenameMethodRefactoring new
		model: (RBNamespace onEnvironment: LibSDL3 asEnvironment);
		renameMethod: #_Bool
		in: LibSDL3
		to: 'bool'
		permutation: #(  );
		renameChanges) execute.
	LibSDL3 removeSelector: #bool
]
