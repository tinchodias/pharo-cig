Extension { #name : 'SDL3GamepadDeviceEvent' }

{ #category : '*CIG-SDL3PostProcessing' }
SDL3GamepadDeviceEvent class >> eventTypeSelectors [

	^ #(#gamepadRemapped #gamepadSteamHandleUpdated #gamepadAdded #gamepadRemoved #gamepadUpdateComplete)
]
