Extension { #name : 'SDL3Scancode' }

{ #category : '*CIG-SDL3PostProcessing' }
SDL3Scancode class >> enumDeclToCamelCaseAt: enumName prefix: prefix givenInvalidName: invalidName [

	^ 'number', invalidName
]
