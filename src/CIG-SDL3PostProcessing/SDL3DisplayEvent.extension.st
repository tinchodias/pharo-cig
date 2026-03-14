Extension { #name : 'SDL3DisplayEvent' }

{ #category : '*CIG-SDL3PostProcessing' }
SDL3DisplayEvent class >> eventTypeSelectors [

	^ #(#displayMoved #displayUsableBoundsChanged #displayRemoved #displayCurrentModeChanged #displayAdded #displayOrientation #displayContentScaleChanged #displayDesktopModeChanged)
]
