Global tp_UPDATE_FREQUENCY:Float = 30 ' times per second
Global tp_UPDATE_TIME:Float = 1000 / tp_UPDATE_FREQUENCY
Global tp_CURRENT_UPDATE_TIME:Float = tp_UPDATE_FREQUENCY

rem
	bbdoc: Set the current Update Frequency.
	about: the default update frequency is 30 times per second
endrem
Function SetUpdateFrequency(v:Float)
	tp_UPDATE_FREQUENCY:Float = v ' times per second
	tp_UPDATE_TIME:Float = 1000 / tp_UPDATE_FREQUENCY
	tp_CURRENT_UPDATE_TIME:Float = tp_UPDATE_FREQUENCY
End Function

