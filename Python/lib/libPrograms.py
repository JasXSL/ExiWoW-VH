out = [
	0,
	# 1 = Arousal max
	[
		-1,
		{"i":1},
		{"i":100,"d":250,"r":1,"e":"Sinusoidal.In"},
		{"i":0},
		{"i":0,"d":500}
	],
	# 2 = Rocket
	[
		-1,
		{},
		{"i":255,"d":1000,"e":"Exponential.In"},
		{"i":1,"d":1000,"e":"Exponential.In"},
		{"i":150,"d":100,"r":8},
		{"i":50,"d":100},
		{"i":50,"d":600},
		{"i":200,"d":0,"r":8},
		{"i":200,"d":200,"r":8},
		{"i":1,"d":0},
		{"i":1,"d":200},
		{"i":200,"d":0},
		{"i":200,"d":200},
		{"i":50,"d":0},
		{"i":20,"d":300},
		{"i":200,"d":0},
		{"i":100,"d":400},
		{"i":50,"d":0},
		{"i":50,"d":200},
		{"i":200,"d":500,"e":"Exponential.In"},
		{"i":1,"d":500,"e":"Exponential.In"}
	],
	# 3 = Pain small
	[
		1,
		{"i":200,"d":0},
		{"i":200,"d":50},
		{"i":1},
		{"d":100}
	],
	# 4 = Pain Large
	[
		0,
		{"i":255,"d":0},
		{"i":255,"d":100},
		{"i":0,"d":1000, "e":"Sinusoidal.In"}
	],
	# 5 = Ars small
	[
		0,
		{"i":70, "d":250},
		{"d":250}
	],
	# 6 = Ars large
	[
		0,
		{"i":0},
		{"i":125, "y":True, "e":"Sinusoidal.InOut", "d":250, "r":1},
		{"d":750, "e":"Sinusoidal.InOut"}
	],
	# 7 = Jade Rod
	[
		-1,
		{"i":1},
		{"i":100,"d":2000,"e":"Sinusoidal.InOut","r":1,"y":1}
	],
	# 8 = Small tickles
	[
		-1,
		{"i":1},
		{"i":50,"d":100,"e":"Sinusoidal.Out","r":1,"y":1}
	],
	# 9 = Idle ooze
	[
		-1,
		{"i":1},
		{"i":20,"d":5000},
		{"i":150,"d":100,"e":"Sinusoidal.Out","r":3,"y":1},
		{"i":1,"d":3000},
		{"i":25,"d":6000},
		{"i":250,"d":100,"e":"Sinusoidal.Out","r":1,"y":1},
		{"i":1,"d":10000},
	],
	#10 = Pulsating mushroom
	[
		-1,
		{"i":1},
		{"i":100,"d":250, "e":"Sinusoidal.In", "r":3,"y":1},
		{"i":0,"d":1000},
		{"i":50,"d":2000, "e":"Bounce.InOut", "r":1, "y":1},
		{"i":0,"d":2000},
	],
	#11 = Pulsating mushroom small
	[
		-1,
		{"i":1},
		{"i":20,"d":10000, "e":"Sinusoidal.InOut"},
		{"i":1,"d":1000},
		{"i":100,"d":2000, "e":"Bounce.InOut", "r":1, "y":1},
		{"i":1,"d":2000},
		{"i":10,"d":30000, "e":"Sinusoidal.InOut"},
		{"i":50,"d":250, "e":"Bounce.InOut", "r":5, "y":1},
		{"i":1, "d":10000}
	],
]