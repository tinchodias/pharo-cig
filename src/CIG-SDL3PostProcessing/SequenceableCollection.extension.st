Extension { #name : 'SequenceableCollection' }

{ #category : '*CIG-SDL3PostProcessing' }
SequenceableCollection >> commonPrefix [

	| prefix |
	prefix := self detectMin: [ :each | each size ].

	prefix withIndexDo: [ :item :i |
		(self allSatisfy: [ :each | (each at: i) = item ])
			ifFalse: [ ^ prefix first: i - 1 ] ].

	^ prefix
]
