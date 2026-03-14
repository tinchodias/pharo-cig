Extension { #name : 'SDL3DropEvent' }

{ #category : '*CIG-SDL3PostProcessing' }
SDL3DropEvent class >> eventTypeSelectors [

	^ #(#dropFile #dropText #dropPosition #dropBegin #dropComplete)
]
