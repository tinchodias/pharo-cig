Extension { #name : 'ByteString' }

{ #category : '*CIG' }
ByteString >> asCamelcasedUnderscores [

	^ String streamContents: [ :writeStream | | readStream |
		readStream := self readStream.
		[ readStream atEnd ] whileFalse: [
			writeStream nextPutAll: (readStream upTo: $_) capitalized ] ]
]
