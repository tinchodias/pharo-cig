Class {
	#name : 'CIGLibSDL3',
	#superclass : 'CIGSDL3Override',
	#category : 'CIG-SDL3PostProcessing-OverridingMethods',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'OverridingMethods'
}

{ #category : 'accessing - platform' }
CIGLibSDL3 >> _macLibraryName [

	^ FFIMacLibraryFinder new
		findAnyLibrary: #('libSDL3.dylib' 'libSDL3.0.dylib')
]

{ #category : 'accessing - platform' }
CIGLibSDL3 >> _unix64LibraryName [

	^ FFIUnix64LibraryFinder new
		findAnyLibrary: #('libSDL3.so' 'libSDL3.so.0.4.0')
]

{ #category : 'accessing - platform' }
CIGLibSDL3 >> _win32LibraryName [

	^ FFIWindowsLibraryFinder new
		findAnyLibrary: #('SDL3.dll')
]
