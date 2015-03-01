Global tp_LOOKUP_FREQUENCY:Float = 30
Global tp_LOOKUP_FREQUENCY_OVERTIME:Float = 1

rem
	bbdoc: Set the lookup frequency for base, variation and global attributes
	about: Default is 30 times per second. This means that the lookup tables for attribute nodes will be accurate to 30 milliseconds which should be accurate enough.
endrem
Function SetLookupFrequency(v:Float)
	tp_LOOKUP_FREQUENCY = v
End Function
rem
	bbdoc: Set the lookup frequency for overtime attributes
	about: Default is 1 time per second. This means that the lookup tables for attribute nodes will be accurate to 1 millisecond which is as accuarte as it can be. Higher
	values will save memory but effect will judder more and be less accurate the higher you go. The memory foot print is very small so 1 should be fine for 99% of apps.
endrem
Function SetLookupFrequencyOvertime(v:Float)
	tp_LOOKUP_FREQUENCY_OVERTIME = v
End Function