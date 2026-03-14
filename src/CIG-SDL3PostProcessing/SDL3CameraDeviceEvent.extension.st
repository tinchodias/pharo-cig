Extension { #name : 'SDL3CameraDeviceEvent' }

{ #category : '*CIG-SDL3PostProcessing' }
SDL3CameraDeviceEvent class >> eventTypeSelectors [

	^ #(#cameraDeviceDenied #cameraDeviceAdded #cameraDeviceApproved #cameraDeviceRemoved)
]
