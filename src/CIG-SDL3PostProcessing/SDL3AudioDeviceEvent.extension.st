Extension { #name : 'SDL3AudioDeviceEvent' }

{ #category : '*CIG-SDL3PostProcessing' }
SDL3AudioDeviceEvent class >> eventTypeSelectors [

	^ #(#audioDeviceRemoved #audioDeviceFormatChanged #audioDeviceAdded)
]
