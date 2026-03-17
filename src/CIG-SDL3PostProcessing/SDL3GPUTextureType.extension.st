Extension { #name : 'SDL3GPUTextureType' }

{ #category : '*CIG-SDL3PostProcessing' }
SDL3GPUTextureType class >> enumDeclToCamelCaseDictionary [

	^ super enumDeclToCamelCaseDictionary
		at: #SDL_GPU_TEXTURETYPE_CUBE put: #atCube;
		at: #SDL_GPU_TEXTURETYPE_CUBE_ARRAY put: #atCubeArray;
		yourself
]
