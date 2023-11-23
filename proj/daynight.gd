tool
extends DirectionalLight

var timeOfDay : float = 0.0
export var freezeTime : bool = false

# Colours
export var dawn : Color = Color(242,155,8)
export var day : Color = Color(255,255,255)
export var dusk : Color = Color(43,45,147)
export var night : Color = Color(17,9,116)

var currentColor : Color

onready var sky : WorldEnvironment


func _ready():
	sky = $WorldEnvironment
	currentColor = Color(242,155,8)
	pass 
	



func _process(delta):
	rotate(Vector3(1,0,0),delta)
	

#	var mix = abs(rotation_degrees.x)/180.0
#
#	if(timeOfDay>0.0&&timeOfDay<15.0):
#		light_color = lerp(currentColor,dawn,mix)
#	elif(timeOfDay>15.0&&timeOfDay<30.0):
#		light_color = lerp(currentColor,day,mix)
#	elif(timeOfDay>30.0&&timeOfDay<45.0):
#		light_color = lerp(currentColor,dusk,mix)
#	elif(timeOfDay>45.0&&timeOfDay<60.0):
#		light_color = lerp(currentColor,night,mix)
#
#
#	#light_color = Color(mix,mix,mix) 
#
#	if(not freezeTime):
#		timeOfDay+=delta*10
#
#
#	if(timeOfDay>60.0):
#		timeOfDay=0.0
#
#	#currentColor = light_color
#	#print(timeOfDay)
#
#
	
