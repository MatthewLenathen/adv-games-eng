shader_type spatial;

uniform sampler2D grassTexture;
uniform sampler2D rockTexture;
uniform sampler2D snowTexture;
uniform sampler2D sandTexture;

uniform vec2 grassRange;
uniform vec2 rockRange;
uniform vec2 snowRange;
uniform vec2 sandRange;

varying float height;
varying vec3 normal;
uniform float slopeFactor;

uniform float snowHeight = 29.0f;
uniform float grassHeight = -1.0f;
uniform float sandHeight = -3.0f;

float calcSlope(float height_normal){
	float slope = 1.0-height_normal;
	slope *= slope;
	return (slope*slopeFactor);
}

float calcMixSandGrass(float heightIn)
{
	if(heightIn > sandHeight && heightIn<grassHeight){
		return 1.0f/(grassHeight/heightIn);
	}
	else if (heightIn > grassHeight){
		return 0.0f;
	}
	else if(heightIn <sandHeight)
	{
		return 1.0f;
	}
}

void vertex(){
    height = VERTEX.y;
    normal = NORMAL;
}

void fragment() {
	
	float slope = clamp(calcSlope(normal.y),0.0,1.0);
	
	vec3 grassColour = texture(grassTexture,UV*grassRange).rgb*0.30;
	//vec3 colour = grassColour;
	vec3 rockColour = texture(rockTexture,UV*rockRange).rgb*0.4;
	vec3 sandColour = texture(sandTexture,UV*sandRange).rgb*0.5;
	vec3 snowColour = texture(snowTexture,UV*snowRange).rgb*0.5;
	vec3 colour;
	if(height>29.0f)
	{
		colour = snowColour;
	}
	else if(height >23.0f &&height<29.0f)
	{
		colour = mix(rockColour,snowColour,slope);
	}
	
	else if (height >-0.5f){
		colour = grassColour;
	}
	else{
		colour = sandColour;
	}
	colour = mix(grassColour,sandColour,calcMixSandGrass(height));
	
	//vec3 testMix = mix(grassColour,sandColour,0.5);
    ALBEDO = colour;
}
