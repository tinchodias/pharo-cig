Class {
	#name : 'CIGSDL3PreSteps',
	#superclass : 'Object',
	#category : 'CIG-SDL3',
	#package : 'CIG-SDL3'
}

{ #category : 'steps' }
CIGSDL3PreSteps class >> step1Generate [

	CigType typeMap at: 'wchar_t' put: #int.

	CigCLibraryGenerator new
		prefix: 'SDL';
		packageName: 'SDL3';
		libraryName: 'SDL3';
		cIncludePath: 'SDL/include' asFileReference;
		cIncludePath: 'SDL/include/SDL3' asFileReference;
		importUnit: '
#include <SDL.h>
';
		withNameGenerator: [ :gen |
			gen stripPrefix: 'SDL_GUID' by: 'guid'.
			gen stripPrefix: 'SDL_GPU' by: 'gpu'.
			gen stripPrefix: 'SDL_EGL' by: 'egl'.
			gen stripPrefix: 'SDL_GL_' by: 'gl'.
			gen stripPrefix: 'create' by: 'new'.
			gen stripPrefix: 'SDL_' ];
		withElementGenerator: [ :gen | gen makeAllFunctionsReturningStringReturnPointer ];
		generate
]

{ #category : 'steps' }
CIGSDL3PreSteps class >> step2RemoveTrash [

	#(SDL3DUMMYENUM BaselineOfSDL3) do: [ :each |
		(self environment at: each) removeFromSystem ]
]

{ #category : 'steps' }
CIGSDL3PreSteps class >> step4FixBool [

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
		assoc traceCr.

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
			Stdio stdout print: each; lf.
			(ReRenameClassRefactoring rename: each key name to: each value) execute ]	
		]
]
