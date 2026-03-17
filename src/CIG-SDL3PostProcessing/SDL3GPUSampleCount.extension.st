Extension { #name : 'SDL3GPUSampleCount' }

{ #category : '*CIG-SDL3PostProcessing' }
SDL3GPUSampleCount class >> enumDeclToCamelCaseDictionary [

	^ super enumDeclToCamelCaseDictionary
		at: #SDL_GPU_SAMPLECOUNT_1 put: #one;
		at: #SDL_GPU_SAMPLECOUNT_2 put: #two;
		at: #SDL_GPU_SAMPLECOUNT_4 put: #four;
		at: #SDL_GPU_SAMPLECOUNT_8 put: #eight;
		yourself
]
