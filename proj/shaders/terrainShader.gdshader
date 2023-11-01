shader_type spatial;

uniform sampler2D grassTexture;
uniform sampler2D rockTexture;
uniform sampler2D snowTexture;

uniform vec2 grassRange;
uniform vec2 rockRange;
uniform vec2 snowRange;

varying float height;
varying vec3 normal;

float calcSlope(float height_normal){
	float slope = 1.0-height_normal;
	slope *= slope;
	//return (slope*slope_factor);
	return 1.0f;
}

void vertex(){
    height = VERTEX.y;
    normal = NORMAL;
}

void fragment() {
    vec3 grassColour = vec3(texture(grassTexture, UV * grassRange).rgb)*0.5;
    vec3 rockColour = vec3(texture(rockTexture, UV * rockRange).rgb)*0.5;
    vec3 snowColour = vec3(texture(snowTexture, UV * snowRange).rgb)*0.5;

    float slope = clamp(calcSlope(normal.y),0.0,1.0);

    vec3 colour = mix(grassColour, rockColour, slope);
    colour = mix(colour, snowColour, slope);

    ALBEDO = colour;
}
