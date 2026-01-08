Extension { #name : 'SDL3ChromaLocation' }

{ #category : '*CIG-SDL3PostProcessing' }
SDL3ChromaLocation class >> enumDeclToCamelCaseDictionary [

	^ super enumDeclToCamelCaseDictionary
		at: #SDL_CHROMA_LOCATION_TOPLEFT put: #topLeft;
		yourself
]
