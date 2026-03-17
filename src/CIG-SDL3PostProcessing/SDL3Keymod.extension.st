Extension { #name : 'SDL3Keymod' }

{ #category : '*CIG-SDL3PostProcessing' }
SDL3Keymod class >> enumDeclToCamelCaseDictionary [

	^ super enumDeclToCamelCaseDictionary
		at: #SDL_KMOD_LSHIFT put: #leftShift;
		at: #SDL_KMOD_RSHIFT put: #rightShift;
		at: #SDL_KMOD_LCTRL put: #leftCtrl;
		at: #SDL_KMOD_RCTRL put: #rightCtrl;
		at: #SDL_KMOD_LALT put: #leftAlt;
		at: #SDL_KMOD_RALT put: #rightAlt;
		at: #SDL_KMOD_LGUI put: #leftGUI;
		at: #SDL_KMOD_RGUI put: #rightGUI;
		yourself
]
