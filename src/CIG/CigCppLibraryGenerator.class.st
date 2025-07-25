"
Generator for C++ libraries. 
In addition to generate Pharo classes to call the library, this generator can generate a bindings library (a library that ""flattens"") the C++ library and creates a set of functions/structures/enums/etc. that can be used with uFFI.

## Example

```smalltalk

(noise := CigCppLibraryGenerator new)
	prefix: 'No';
	bindingsName: 'noise';
	file: '/home/esteban/dev/vm/libnoise/include/noise/noise.h';
	cIncludePath: '/home/esteban/dev/vm/libnoise/include';
	cIncludePath: '/home/esteban/dev/vm/libnoise/include/noise';
	cLib: 'noise';
	withCBindings;
	withMakefile;
	withClasses.
	
noise generate.
noise buildBindingsLibrary.
```
"
Class {
	#name : 'CigCppLibraryGenerator',
	#superclass : 'CigLibraryGenerator',
	#instVars : [
		'withMakefile',
		'withCBindings',
		'cClassSpecializations',
		'withSpecialElements',
		'shouldBuildBindingsLibrary'
	],
	#category : 'CIG-Base',
	#package : 'CIG',
	#tag : 'Base'
}

{ #category : 'translating' }
CigCppLibraryGenerator class >> translateUnitWithoutSpecial: aFileName [

	^ self new
		import: aFileName;
		withoutSpecialElements;
		translateUnit
]

{ #category : 'accessing - configuration' }
CigCppLibraryGenerator >> buildBindingsLibrary [

	shouldBuildBindingsLibrary := true
]

{ #category : 'accessing - configuration' }
CigCppLibraryGenerator >> cClassSpecializations [

	^ cClassSpecializations

]

{ #category : 'accessing - configuration' }
CigCppLibraryGenerator >> cClassSpecializations: aDictionary [

	cClassSpecializations := aDictionary
]

{ #category : 'accessing - scripting' }
CigCppLibraryGenerator >> cSpecialize: aTemplateName [
	"add a direct class specialization (process of generation will try to detect the ones 
	 client use, but sometimes you want to add some extra maps to use by yourself that are 
	 not specified."

	cClassSpecializations ifNil: [ cClassSpecializations := Set new ].
	cClassSpecializations add: aTemplateName
]

{ #category : 'accessing - configuration' }
CigCppLibraryGenerator >> doNotBuildBindingsLibrary [

	shouldBuildBindingsLibrary := false
]

{ #category : 'generating' }
CigCppLibraryGenerator >> generate [
	| unit |

	logger trace: self libraryName.
	
	unit := self translateUnit.

	self hasCBindings ifTrue: [ self generateCBindingsWith: unit ].
	self hasMakefile ifTrue: [ self generateMakefile ].
	self hasClasses ifTrue: [ self generatePharoClassesWith: unit ].
	self hasBaseline ifTrue: [ self generatePharoBaselineWith: unit ].
	self shouldBuildBindingsLibrary ifTrue: [ self generateBindingsLibrary ]
]

{ #category : 'generating' }
CigCppLibraryGenerator >> generateBindingsLibrary [
	
	logger trace.
	CigMakefile executeFor: self
]

{ #category : 'generating' }
CigCppLibraryGenerator >> generateCBindingsWith: unit [
	| bindingsFileName |

	bindingsFileName := self cFileReference basename.
	logger trace: bindingsFileName.
	CigCVisitor new
		file: self;
		visit: unit
]

{ #category : 'generating' }
CigCppLibraryGenerator >> generateMakefile [
	| template |

	logger trace.

	template := '
INCLUDE_DIRS={include}
LIBS={libs}

../lib/{libName}.so: {libName}.cpp
	clang -xc++ -fPIC --shared $(INCLUDE_DIRS) $(LIBS) {libName}.cpp -o ../lib/{libName}.so
' format: { 
		#libName->self libraryName.
		#include->(String streamContents: [ :stream | 
			self cIncludePathsAsArguments 
				do: [ :each | stream nextPutAll: each asString ] 
				separatedBy: [ stream nextPut: Character space ] ]).
		#libs->(String streamContents: [ :stream | 
			self cLibsAsArguments 
				do: [ :each | stream nextPutAll: each asString ] 
				separatedBy: [ stream nextPut: Character space ] ]) }
	asDictionary.

	self makefileReference 
		ensureDelete;
		writeStreamDo: [ :stream |
			(ZnNewLineWriterStream on: stream) << template ]
]

{ #category : 'testing' }
CigCppLibraryGenerator >> hasCBindings [

	^ withCBindings
]

{ #category : 'testing' }
CigCppLibraryGenerator >> hasMakefile [

	^ withMakefile
]

{ #category : 'testing' }
CigCppLibraryGenerator >> hasSpecialElements [

	^ withSpecialElements
]

{ #category : 'initialization' }
CigCppLibraryGenerator >> initialize [

	super initialize.
	self withSpecialElements.
	self withCBindings.
	self withMakefile.
	self buildBindingsLibrary
]

{ #category : 'accessing' }
CigCppLibraryGenerator >> makefileReference [
	
	^ self cFileReference parent / 'Makefile'
]

{ #category : 'private' }
CigCppLibraryGenerator >> newTranslatedUnit [

	^ CigCppTranslatedUnit new
]

{ #category : 'testing' }
CigCppLibraryGenerator >> shouldBuildBindingsLibrary [

	^ shouldBuildBindingsLibrary
]

{ #category : 'accessing - configuration' }
CigCppLibraryGenerator >> withCBindings [

	withCBindings := true
]

{ #category : 'accessing - configuration' }
CigCppLibraryGenerator >> withMakefile [

	withMakefile := true
]

{ #category : 'accessing - configuration' }
CigCppLibraryGenerator >> withSpecialElements [

	withSpecialElements := true
]

{ #category : 'accessing - configuration' }
CigCppLibraryGenerator >> withoutCBindings [

	withCBindings := false
]

{ #category : 'accessing - configuration' }
CigCppLibraryGenerator >> withoutMakefile [

	withMakefile := false
]

{ #category : 'accessing - configuration' }
CigCppLibraryGenerator >> withoutSpecialElements [

	withSpecialElements := false
]
