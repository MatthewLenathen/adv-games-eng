tool
extends DirectionalLight

var lengthOfDay = 30
var gameTick : float = 0.0
var rotationSpeed = 0.0

export var freezeTime : bool = false

# Colours
export var dawn : Color = Color(0.8,0.6,0.2)
export var day : Color = Color(0.8,0.8,0.5)
export var dusk : Color = Color(0.167,0.176,0.576)
export var night : Color = Color(0.067,0.035,0.455)
var sky_color = Color(0.0,0.3,1.0)

var currentColor : Color

onready var sky : WorldEnvironment


func _ready():
	
	currentColor = dawn
	light_color = currentColor
	gameTick=0
	rotationSpeed = (2.0*PI)/lengthOfDay
	rotation.x = 0.0
	rotation.y = 0.0
	rotation.z = 0.0
	sky = get_parent()

func changeSkyColour():
	if sky == null:
		return;
		
	if sky.environment.background_mode == Environment.BG_COLOR:
		sky.environment.background_color = lerp(sky_color, currentColor, 0.5)
		sky.environment.ambient_light_color = sky.environment.background_color

func _process(delta):
	if(freezeTime):
		return
		
	changeSkyColour()
	rotate_x(-rotationSpeed*delta)
	
	

	var mix = abs(sin(rotation.x))
	
	if(rotation.x<0 and rotation.x>-PI/2.0):
		light_color = lerp(dawn,day,mix)
		
	elif(rotation.x<-PI/2.0 and rotation.x>-PI):
		light_color = lerp(day,dusk,1.0-mix)
		
	elif(rotation.x<PI and rotation.x>PI/2.0):
		light_color = lerp(dusk,night,mix)
		
	else:
		light_color = lerp(night,dawn,1.0-mix)
		
	currentColor = light_color
		
	if(gameTick>lengthOfDay):
		gameTick=0

	



