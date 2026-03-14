Extension { #name : 'SDL3TouchFingerEvent' }

{ #category : '*CIG-SDL3PostProcessing' }
SDL3TouchFingerEvent class >> eventTypeSelectors [

	^ #(#fingerDown #fingerMotion #fingerCanceled #fingerUp)
]
