Extension { #name : 'SDL3JoyDeviceEvent' }

{ #category : '*CIG-SDL3PostProcessing' }
SDL3JoyDeviceEvent class >> eventTypeSelectors [

	^ #(#joystickAdded #joystickRemoved #joystickUpdateComplete)
]
