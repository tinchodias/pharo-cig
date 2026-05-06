Class {
	#name : 'CIGSDL3PostSteps',
	#superclass : 'Object',
	#category : 'CIG-SDL3PostProcessing-Core',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'Core'
}

{ #category : 'steps' }
CIGSDL3PostSteps class >> step00FixBool [

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

{ #category : 'steps' }
CIGSDL3PostSteps class >> step0Override [

	CIGSDL3Override applyOnAllSubclasses
]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step1RemoveMetaEventTypes [

	SDL3EventType classSide methods
		select: [ :each | (each selector endsWith: '_FIRST') or: [ each selector endsWith: '_LAST' ] ]
		thenDo: [ :each |
			each removeFromSystem.
			SDL3EventType removeClassVarNamed: each selector ].

	"Need any of this? SDL3EventType initializeEnumeration; rebuildEnumAccessors"

	"SDL3EventType classVarNames
		select: [ :each | (each endsWith: '_FIRST') or: [ each endsWith: '_LAST' ] ]
		thenDo: [ :each | 	SDL3EventType removeClassVarNamed: each ]."
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
	evts do: [ :e | e superclass: eventClass ].

	eventClass classSide
		compile: 'eventTypeSelectors<r><r><t>^ #()' expandMacros
		classified: '*CIG-SDL3PostProcessing'
]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step4bSDL3WindowIDEvent [

	| mappedEventClass eventClass |
	mappedEventClass := self environment at: #SDL3MappedEvent.
	eventClass :=
		(mappedEventClass << #SDL3WindowIDEvent
			slots: {};
			tag: 'Own';
			package: 'SDL3') install.

	(mappedEventClass subclasses copyWithout: eventClass)
		select: [ :each | each includesSelector: #windowID ]
		thenDo: [ :each | each superclass: eventClass ]
]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step4cSDL3MouseEvent [

	| eventClass |
	"TODO: chasing cycle"
"	self environment at: #SDL3MouseEvent ifPresent: #removeFromSystem."
	self assert: (self environment includesKey: #SDL3MouseEvent) not.
	eventClass :=
		((self environment at: #SDL3WindowIDEvent) << #SDL3MouseEvent
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
CIGSDL3PostSteps class >> step4dMoreIntermediateEvents [

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
CIGSDL3PostSteps class >> step4eInsertLeavesByType [
	"... and compile all #eventType.
	SDL3CommonEvent is the only subclass that doesn't have event type"

	| compileBlock |
	compileBlock := [ :eventClass :typeSelector |
		eventClass classSide
			compile: ('eventType

	^ SDL3EventType ', typeSelector asString)
			classified: 'accessing' ].

	SDL3MappedEvent classSide
		compile: 'eventType
	"Answer the `SDL3EventType` associated to this event. Non-leaf subclasses and `SDL3CommonEvent` answer nil."

	^ nil'
		classified: 'accessing'.

	SDL3MappedEvent allSubclasses
		reject: [ :each | each eventTypeSelectors isEmpty ]
		thenDo: [ :each |
			each eventTypeSelectors size > 1
				ifFalse: [
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
CIGSDL3PostSteps class >> step4zEventVisitor [
	"Add visitor API"

	SDL3MappedEvent withAllSubclassesDo: [ :each |
		each compile: ('accept: aVisitor

	^ aVisitor visit{1}: self' format: { each name withoutPrefix: 'SDL3' })
			classified: 'visitor' ]
]

{ #category : 'steps' }
CIGSDL3PostSteps class >> step4zzEventVisitorTrait [

	| eventClass |
	eventClass :=
		(Trait << #TSDL3HierarchicalEventVisitor
			tag: 'Events';
			package: 'SDL3') install.
	eventClass comment: 'I am a trait providing a double-dispatch mechanism for visiting `SDL3MappedEvent` objects.
I implement a ''bubbling'' delegation pattern: specific visit methods (e.g., #visitMouseButtonDownEvent:) delegate to more general ones (e.g., #visitMouseButtonEvent:), eventually terminating in a no-op at #visitMappedEvent:.

Users should compose me into any class that needs to process SDL3 events. This allows subclasses to selectively override only the specific events they care about, while high-level or unhandled events automatically fall back to the next level of generality.'.

	SDL3MappedEvent allSubclassesDo: [ :each |
		eventClass
			compile: ('visit{1}: anEvent

	^ self visit{2}: anEvent'
				format: {
					each name withoutPrefix: 'SDL3'.
					each superclass name withoutPrefix: 'SDL3' })
			classified: 'visiting - ', (each hasSubclasses ifTrue: [ 'abstract' ] ifFalse: [ 'concrete' ] ) ].

	eventClass
		compile: 'visitMappedEvent: aVisitor'
		classified: 'visiting - root'
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
CIGSDL3PostSteps class >> step8CreateAllEnumerations [

	| class |
	class := (SharedPool << #SDL3AllEnumerations
		sharedPools: SDL3Enumeration allSubclasses;
		tag: 'Enumerations';
		package: 'SDL3') install.
	class comment: 'I am a shared pool that gathers all SDL3 enumerations, which eases their usage.'
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
