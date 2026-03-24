Extension { #name : 'SDL3Keycode' }

{ #category : '*CIG-SDL3-Own' }
SDL3Keycode class >> enumDeclToCamelCaseAt: aName prefix: prefix givenInvalidName: invalidName [

	invalidName first isDigit ifFalse: [ self error ].

	^ 'number', invalidName
]

{ #category : '*CIG-SDL3-Own' }
SDL3Keycode class >> enumDeclToCamelCaseDictionary [
	"
	self enumDeclToCamelCaseDictionary
	"
	| dict |
	dict := super enumDeclToCamelCaseDictionary.

	dict associations do: [ :assoc |

		(assoc value beginsWith: 'kp') ifTrue: [
			dict at: assoc key put: ('keypad', (assoc value withoutPrefix: 'kp') capitalized) ].

		(assoc value endsWith: 'paren') ifTrue: [
			dict at: assoc key put: ((assoc value withoutSuffix: 'paren'), 'Parenthesis') ].

		#(brace bracket up down left right lock separator unit again minus colon) do: [ :suffix |
			(assoc value endsWith: suffix) ifTrue: [
				dict
					at: assoc key
					put: ((assoc value withoutSuffix: suffix), suffix capitalized) uncapitalized ] ].

		(assoc value includesSubstring: 'dbl' caseSensitive: false) ifTrue: [
			| index |
			index := assoc value findString: 'dbl' startingAt: 1 caseSensitive: false.
			dict
				at: assoc key
				put:
					((assoc value first: index - 1),
					'Double',
					(assoc value allButFirst: index + 'dbl' size - 1) capitalized)
						uncapitalized ].
		].


	dict
		at: #SDLK_HASH put: #hashKey; "avoid overriding #hash"
		at: #SDLK_LMETA put: #leftMeta;
		at: #SDLK_RMETA put: #rightMeta;
		at: #SDLK_LHYPER put: #leftHyper;
		at: #SDLK_RHYPER put: #rightHyper;
		at: #SDLK_LSHIFT put: #leftShift;
		at: #SDLK_RSHIFT put: #rightShift;
		at: #SDLK_LCTRL put: #leftCtrl;
		at: #SDLK_RCTRL put: #rightCtrl;
		at: #SDLK_LALT put: #leftAlt;
		at: #SDLK_RALT put: #rightAlt;
		at: #SDLK_LGUI put: #leftGUI;
		at: #SDLK_RGUI put: #rightGUI.

	^ dict
]
