Class {
	#name : 'CIGSDL3PreSteps',
	#superclass : 'Object',
	#category : 'CIG-SDL3',
	#package : 'CIG-SDL3'
}

{ #category : 'steps' }
CIGSDL3PreSteps class >> apply [

	self step1Generate.
	self step2RemoveTrash.
	self step3AddMappedEvent.
	self step4PatchRBMethod.
	self step5RenameAPI.
	self step6RenameClasses
]

{ #category : 'steps' }
CIGSDL3PreSteps class >> step1Generate [

	| lib |
	lib := CigCLibraryGenerator new.
	lib
	  prefix: 'S3';
	  packageName: 'SDL3';
	  libraryName: 'SDL3'.
	lib
	  cIncludePath: './';
	  cIncludePath: './SDL';
	  cIncludePath: '/usr/include'.

	{'_Bool'. #bool.
	'const _Bool'. #bool.
	'signed char'. #char.
	'wchar_t'. #int.
	} pairsDo: [ :a :b |
		CigType typeMap at: a put: b ].


	lib import: '/usr/include/stdint.h'.
	lib import: './SDL/include/SDL3/SDL_assert.h'.
	lib import: './SDL/include/SDL3/SDL_platform_defines.h'.
	lib import: './SDL/include/SDL3/SDL_stdinc.h'.
	lib import: './SDL/include/SDL3/SDL_properties.h'.
	lib import: './SDL/include/SDL3/SDL_error.h'.

	"basic utils (generally need only SDL_stdinc and SDL_error)"

	lib import: './SDL/include/SDL3/SDL_version.h'.
	lib import: './SDL/include/SDL3/SDL_init.h'.
	lib import: './SDL/include/SDL3/SDL_time.h'.																		
	lib import: './SDL/include/SDL3/SDL_timer.h'.
	lib import: './SDL/include/SDL3/SDL_clipboard.h'.
	lib import: './SDL/include/SDL3/SDL_cpuinfo.h'.
	lib import: './SDL/include/SDL3/SDL_filesystem.h'.
	lib import: './SDL/include/SDL3/SDL_misc.h'.


	"video stuff"

	lib import: './SDL/include/SDL3/SDL_endian.h'.
	lib import: './SDL/include/SDL3/SDL_pixels.h'.
	lib import: './SDL/include/SDL3/SDL_rect.h'.
	lib import: './SDL/include/SDL3/SDL_blendmode.h'.
	lib import: './SDL/include/SDL3/SDL_iostream.h'.
	lib import: './SDL/include/SDL3/SDL_surface.h'.
	lib import: './SDL/include/SDL3/SDL_video.h'.
	lib import: './SDL/include/SDL3/SDL_render.h'.
	lib import: './SDL/include/SDL3/SDL_gpu.h'.

	"utils that need video"

	lib import: './SDL/include/SDL3/SDL_dialog.h'.
	lib import: './SDL/include/SDL3/SDL_messagebox.h'.

	"input and events stuff"

	lib import: './SDL/include/SDL3/SDL_sensor.h'.
	lib import: './SDL/include/SDL3/SDL_mouse.h'.
	lib import: './SDL/include/SDL3/SDL_touch.h'.
	lib import: './SDL/include/SDL3/SDL_pen.h'.

	lib import: './SDL/include/SDL3/SDL_scancode.h'.
	lib import: './SDL/include/SDL3/SDL_keycode.h'.
	lib import: './SDL/include/SDL3/SDL_keyboard.h'.

	lib import: './SDL/include/SDL3/SDL_atomic.h'.
	lib import: './SDL/include/SDL3/SDL_thread.h'.
	lib import: './SDL/include/SDL3/SDL_mutex.h'.
	lib import: './SDL/include/SDL3/SDL_audio.h'.

	lib import: './SDL/include/SDL3/SDL_camera.h'.
	lib import: './SDL/include/SDL3/SDL_power.h'.

	lib import: './SDL/include/SDL3/SDL_guid.h'.
	lib import: './SDL/include/SDL3/SDL_joystick.h'.

	lib import: './SDL/include/SDL3/SDL_events.h'.

	"other features"
	lib import: './SDL/include/SDL3/SDL_asyncio.h'.
	lib import: './SDL/include/SDL3/SDL_loadso.h'.
	lib import: './SDL/include/SDL3/SDL_locale.h'.
	lib import: './SDL/include/SDL3/SDL_platform.h'.
	lib import: './SDL/include/SDL3/SDL_system.h'.
	lib import: './SDL/include/SDL3/SDL_tray.h'.


	"Generation signals an error, but the main work is done anyway:"
	lib generate

]

{ #category : 'steps' }
CIGSDL3PreSteps class >> step2RemoveTrash [

	(#S3SDL_DUMMY_ENUM asClassInEnvironment: self environment) removeFromSystem.
	(#S3SDL_alignment_test asClassInEnvironment: self environment) removeFromSystem.

	((#S3BaseObject asClassInEnvironment: self environment) allSubclasses,
	(#S3Structure asClassInEnvironment: self environment) allSubclasses)
		select: [ :each | each name endsWith: '0' ] thenDo: #removeFromSystem
]

{ #category : 'steps' }
CIGSDL3PreSteps class >> step3AddMappedEvent [

	"Create S3SDLMappedEvent and make all events subclass of it with:"
	| c evts |
	c :=
		((self environment at: #S3Structure) << #S3SDLMappedEvent
			slots: {};
			tag: 'Own';
			package: 'SDL3') install.

	evts := (self environment at: #S3Structure) subclasses
		select: [ :each | each name endsWith: 'Event' ].
	evts := evts copyWithout: c.
	evts do: [ :e | e superclass: c ].
]

{ #category : 'steps' }
CIGSDL3PreSteps class >> step4PatchRBMethod [

	RBMethod compile: 'refersToSymbol: aSymbol

		| searcher |
		searcher := self parserTreeSearcher.
		searcher
			matches: aSymbol printString do: [ :node :answer | true ];
			matches: ''`#literal'' do: [ :node :answer |
				answer or: [
				(node parent isMessage and: [(node parent selector beginsWith: ''ffiCall'') not]) and: [
				self literal: node value containsReferenceTo: aSymbol ] ] ].
		aSymbol isValidSelector ifTrue: [
			searcher
				matches: ''`@object ''
					, (self parseTreeSearcherClass buildSelectorString: aSymbol)
				do: [ :node :answer | true ] ].
		^ searcher executeTree: self parseTree initialAnswer: false'.
]

{ #category : 'steps' }
CIGSDL3PreSteps class >> step5RenameAPI [

	| prefixRules renames env model allChanges |
	prefixRules := {
		'SDL_GL_' -> 'gl'.
		'SDL_EGL_' -> 'egl'.
		'SDL_GPU' -> 'gpu'.
		'SDL_GUID' -> 'guid'.
		'SDL_Create' -> 'new'.
		'SDL_' -> '' }.

	"First pass, fix prefixes"
	renames := LibSDL3 selectors sorted
		select: [ :each | prefixRules anySatisfy: [ :rule | each beginsWith: rule key ] ] 
		thenCollect: [ :oldSelector |
			| newSelector rule |
			rule := prefixRules detect: [ :r | oldSelector beginsWith: r key ].
			newSelector := oldSelector allButFirst: rule key size.
			newSelector := rule value, newSelector.
			oldSelector -> newSelector ].

	"Convert underscores to CamelCase"
	renames withIndexDo: [ :assoc :index |
		| newSelector |
		newSelector := assoc value.
		(assoc value includes: $_) ifTrue: [
			newSelector :=
				String streamContents: [ :writeStream | | readStream |
					readStream := newSelector readStream.
					[ readStream atEnd ] whileFalse: [
						writeStream nextPutAll: (readStream upTo: $_) capitalized ] ].
			renames
				at: index
				put: assoc key -> newSelector ] ].

	"Make first letter lowercase"
	renames withIndexDo: [ :assoc :index |
		| newSelector |
		newSelector := assoc value.
		newSelector at: 1 put: (newSelector first asLowercase).
		renames
			at: index
			put: assoc key -> newSelector ].

	env := RBPackageEnvironment packageNames: #('SDL3' "'SDL3-Own' 'SDL3-Tests'").
	model := RBNamespace onEnvironment: env.
	allChanges := renames flatCollect: [ :assoc |
		| changes |
		changes := (ReRenameMethodRefactoring new
	        model: model;
	        renameMethod: assoc key
	        	in: LibSDL3
				to: assoc value
				permutation: (1 to: assoc key numArgs);
	        renameChanges) changes ].

	allChanges do: #generateChanges
]

{ #category : 'steps' }
CIGSDL3PreSteps class >> step6RenameClasses [

	#(
	'S3SDL_'
	'S3SDL3'
	'S3SDL'
	'S3'
	) do: [ :oldPrefix |
			| renames |
			renames := Smalltalk allClassesAndTraits
				select: [ :each | each name beginsWith: oldPrefix ]
				thenCollect: [ :each |
					| newName |
					"Remove old prefix"
					newName := each name withoutPrefix: oldPrefix.

					"Convert underscores to CamelCase"
					newName := String streamContents: [ :writeStream | | readStream |
							readStream := newName readStream.
							[ readStream atEnd ] whileFalse: [
								writeStream nextPutAll: (readStream upTo: $_) capitalized ] ].

					"Add the new prefix"
					newName := 'SDL3', newName.

					each -> newName ].

		renames do: [ :each |
			(ReRenameClassRefactoring rename: each key name to: each value) execute ]	
		]
]
