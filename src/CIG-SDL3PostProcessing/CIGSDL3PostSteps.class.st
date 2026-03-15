Class {
	#name : 'CIGSDL3PostSteps',
	#superclass : 'Object',
	#category : 'CIG-SDL3PostProcessing-Core',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'Core'
}

{ #category : 'steps' }
CIGSDL3PostSteps class >> step0Override [

	CIGSDL3Override applyOnAllSubclasses
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
				| renameChanges |
				(oldName -> newName) traceCr.

				[renameChanges := ReRenameMethodRefactoring new
			        model: model;
			        renameMethod: oldName
			        	in: enumClass classSide
						to: newName
						permutation: #();
			        renameChanges.
				allChanges addAll: renameChanges changes ]
					on: RBRefactoringError
					do: [ :e | e traceCr ] ].

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
			(oldName -> newName) traceCr.

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
CIGSDL3PostSteps class >> step4aSDL3MappedEvent [

	| eventClass evts |
	eventClass :=
		(SDL3Structure << #SDL3MappedEvent
			slots: {};
			tag: 'Own';
			package: 'SDL3') install.

	evts := SDL3Structure subclasses
		select: [ :each | each name endsWith: 'Event' ].
	evts := evts copyWithout: eventClass.
	evts do: [ :e | e superclass: eventClass ]
]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step4bSDL3WindowIDEvent [

	| eventClass |
	eventClass :=
		(SDL3MappedEvent << #SDL3WindowIDEvent
			slots: {};
			tag: 'Own';
			package: 'SDL3') install.

	SDL3MouseEvent superclass: eventClass.

	SDL3MappedEvent subclasses
		select: [ :each | each includesSelector: #windowID ]
		thenDo: [ :each | each superclass: eventClass ]
]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step4cSDL3MouseEvent [

	| eventClass |
	eventClass :=
		(SDL3MappedEvent << #SDL3MouseEvent
			slots: {};
			tag: 'Own';
			package: 'SDL3') install.

	SDL3MappedEvent allSubclasses
		select: [ :each |
			(each name includesSubstring: 'Mouse')
			and: [ (each includesSelector: #which)
			and: [ (each includesSelector: #x) ] ] ]
		thenDo: [ :each | each superclass: eventClass ]
]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step4dMore [

	| eventClass |
	eventClass :=
		(SDL3MappedEvent << #SDL3DeviceEvent
			slots: {};
			tag: 'Own';
			package: 'SDL3') install.
	eventClass comment: 'My subclasses are related to a pluggable device'.

	(SDL3MappedEvent allSubclasses copyWithout: eventClass)
		select: [ :each |
			(each name includesSubstring: 'Device')
			and: [ each superclass = SDL3MappedEvent ] ]
		thenDo: [ :each | each superclass: eventClass ].

"---"

	eventClass :=
		(SDL3MappedEvent << #SDL3GamepadEvent
			slots: {};
			tag: 'Own';
			package: 'SDL3') install.
	eventClass comment: 'My subclasses are related to a gamepad.'.

	(SDL3MappedEvent allSubclasses copyWithout: eventClass)
		select: [ :each |
			(each name includesSubstring: 'Gamepad')
			and: [ each superclass = SDL3MappedEvent ] ]
		thenDo: [ :each | each superclass: eventClass ].

"---"

	eventClass :=
		(SDL3WindowIDEvent << #SDL3PenEvent
			slots: {};
			tag: 'Own';
			package: 'SDL3') install.
	eventClass comment: 'My subclasses are related to a pen device.'.

	(SDL3MappedEvent allSubclasses copyWithout: eventClass)
		select: [ :each |
			(each name includesSubstring: 'Pen')
			and: [ each superclass = SDL3WindowIDEvent ] ]
		thenDo: [ :each | each superclass: eventClass ].

"---"

	eventClass :=
		(SDL3MappedEvent << #SDL3JoystickEvent
			slots: {};
			tag: 'Own';
			package: 'SDL3') install.
	eventClass comment: 'My subclasses are related to a joystick.'.

	(SDL3MappedEvent allSubclasses copyWithout: eventClass)
		select: [ :each |
			(each name includesSubstring: 'Joy')
			and: [ each superclass = SDL3MappedEvent ] ]
		thenDo: [ :each | each superclass: eventClass ].

"---"

	eventClass :=
		(SDL3WindowIDEvent << #SDL3TextEvent
			slots: {};
			tag: 'Own';
			package: 'SDL3') install.
	eventClass comment: 'My subclasses are related to text input.'.

	(SDL3MappedEvent allSubclasses copyWithout: eventClass)
		select: [ :each |
			(each name includesSubstring: 'Text')
			and: [ each superclass = SDL3WindowIDEvent ] ]
		thenDo: [ :each | each superclass: eventClass ].

]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step4zEventVisitor [
	"Add visitor API"

	SDL3MappedEvent withAllSubclassesDo: [ :each |
		each compile: ('accept: aVisitor

	^ aVisitor visit{1}: self' format: { each name withoutPrefix: 'SDL3' })
			classified: 'visitor' ]
]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step4zzFineGrainedEvents [

	"SDL3CommonEvent is the only subclass that doesn't have event type"

	| compileBlock |
	compileBlock := [ :eventClass :typeSelector |
			eventClass classSide
				compile: ('eventType

	^ SDL3EventType ', typeSelector asString)
				classified: 'accessing' ].


	(SDL3MappedEvent allSubclasses copyWithout: SDL3CommonEvent) do: [ :each |
		each eventTypeSelectors size > 1
			ifFalse: [
				self assert: each eventTypeSelectors size = 1.
				compileBlock value: each value: each eventTypeSelectors first ]
			ifTrue: [
				| prefix |
				prefix := each eventTypeSelectors commonPrefix.
				each eventTypeSelectors do: [ :eachType |
					| insert newName newClass |
					insert := eachType withoutPrefix: prefix.
					newName := (each name withoutSuffix: 'Event'), insert, 'Event'.
					newClass := (each << newName asSymbol
						slots: {};
						tag: 'Events';
						package: 'SDL3') install.

					newClass comment: ('I represent the `{1}` SDL3 event type. My FFI structure fields and their corresponding accessing protocol are defined on my superclass.' format: { (SDL3EventType perform: eachType) item }).

					compileBlock value: newClass value: eachType ].
		] ]
]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step4zzzEventsTag [

	"Set package tag of other existing classes"
	SDL3MappedEvent withAllSubclassesDo: [:each | each packageTag: 'Events' ]
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
CIGSDL3PostSteps class >> step6DeleteDispose [

	SDL3BaseObject allSubclassesDo: [ :each | each removeSelector: #dispose ].
	SDL3BaseObject compile: 'dispose
	"Hook sent on finalization"' classified: #finalization
]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step7DeleteUnneededStructAPI [

	SDL3Structure allSubclassesDo: [ :each |
		{#reserved.
		#padding1.
		#padding2.
		#padding3.
		#padding4} do: [ :eachSelector |
			each
				removeSelector: eachSelector;
				removeSelector: (eachSelector, ':') asSymbol ] ]
]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step99AddGitRepo [

	| remote repository |
	remote := IceGitRemote url: 'https://github.com/pharo-graphics/PharoSDL3.git'.
	repository :=
		IceRepositoryCreator new
			remote: remote;
			location: 'src' asFileReference;
			createRepository.
	repository
		name: 'PharoSDL3';
		register;
		fetch
]
