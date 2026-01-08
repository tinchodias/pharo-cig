Class {
	#name : 'CIGSDL3Override',
	#superclass : 'Object',
	#category : 'CIG-SDL3PostProcessing-OverridingMethods',
	#package : 'CIG-SDL3PostProcessing',
	#tag : 'OverridingMethods'
}

{ #category : 'private' }
CIGSDL3Override class >> apply [

	{self classSide. self instanceSide} do: [ :eachBehavior |
		eachBehavior methods do: [ :eachMethod |
			| behaviorName behaviorToApply overridingCode |
			eachMethod displayString traceCr.

			behaviorName := eachMethod origin instanceSide name withoutPrefix: 'CIG'.
			behaviorToApply := self environment at: behaviorName asSymbol.
			eachMethod isClassSide ifTrue: [
				behaviorToApply := behaviorToApply classSide ].
			overridingCode := eachMethod sourceCode withoutPrefix: '_'.
			behaviorToApply compile: overridingCode classified: eachMethod protocolName
			] ]
]

{ #category : 'private' }
CIGSDL3Override class >> applyOnAllSubclasses [
	<script>

	self allSubclassesDo: #apply
]
