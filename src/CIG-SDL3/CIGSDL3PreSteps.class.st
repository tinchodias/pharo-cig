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
		prefix: 'S3';
		packageName: 'SDL3';
		libraryName: 'SDL3';
		cIncludePath: 'SDL/include' asFileReference;
		cIncludePath: 'SDL/include/SDL3' asFileReference;
		importUnit: '
#define DOXYGEN_SHOULD_IGNORE_THIS
#define SDL_WIKI_DOCUMENTATION_SECTION
#include <SDL.h>
';
		withNameGenerator: [ :gen |
			gen stripPrefix: 'SDL_GUID' by: 'guid'.
			gen stripPrefix: 'SDL_GPU' by: 'gpu'.
			gen stripPrefix: 'SDL_UCS4' by: 'ucs4'.
			gen stripPrefix: 'SDL_IO' by: 'io'.

			gen stripPrefix: 'SDL_Metal_' by: 'metal'.
			gen stripPrefix: 'SDL_EGL_' by: 'egl'.
			gen stripPrefix: 'SDL_GL_' by: 'gl'.
			gen stripPrefix: 'SDL_'.

			gen stripPrefix: 'create' by: 'new'.
			];
		withElementGenerator: [ :gen | gen makeAllFunctionsReturningStringReturnPointer ];
		generate
]

{ #category : 'steps' }
CIGSDL3PreSteps class >> step2RenameClasses [
	"Unify prefixes and remove underscores"

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

{ #category : 'steps' }
CIGSDL3PreSteps class >> step3RemoveBaseline [
	"We have our own already"

	(self environment at: #BaselineOfSDL3) removeFromSystem
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
