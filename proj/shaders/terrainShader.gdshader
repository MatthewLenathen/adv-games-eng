shader_type spatial;

// Texture samplers and ranges
uniform sampler2D grassTexture;
uniform sampler2D rockTexture;
uniform sampler2D snowTexture;
uniform sampler2D sandTexture;
uniform vec2 grassRange;
uniform vec2 rockRange;
uniform vec2 snowRange;
uniform vec2 sandRange;

// Get values from vertex shader
varying float height;
varying vec3 normal;

// Define ranges for where different textures appear, give default values as a baseline
uniform float slopeFactor = 5.0f;
uniform float snowHeight = 30.0f;
uniform float grassHeight = 13.0f;
uniform float beachStart = -2.0f;
uniform float beachFinish = 0.0f;

// returns a clamped slope float based on the incoming normal, need to clamp for use in mix
float calculateSlope(float normal_y){
	float slope = 1.0-normal_y; // e.g, flat surface normal = 1.0, giving a slope of 0
	slope *= slope;
	return clamp(slope*slopeFactor,0.0,1.0);
}	


float calculateBeachMix(float heightIn) {
    // Returns 0.0 when below beach_start_height, 1.0 above beach_end_height, and a smoothstep in between
    return smoothstep(beachStart, beachFinish, heightIn);
}

float calculateSnowMix(float heightIn) {
	// Same idea as beachmix, returns, 0.0 when below grass, 1.0 when above snowHeight and smooth inbetween
	// Through this method, we can adjust the various height variables to get the desired effect
	return smoothstep(grassHeight,snowHeight,heightIn);
}

// Vertex shader giving us height and normal
void vertex(){
    height = VERTEX.y;
    normal = NORMAL;
}

void fragment() {
	// Calculate the slope and height factors
	float slope = calculateSlope(normal.y);
    float snowMix = calculateSnowMix(height);
    float beachMix = calculateBeachMix(height);
	
	vec3 grassColour = texture(grassTexture,UV*grassRange).rgb*0.5;
	vec3 rockColour = texture(rockTexture,UV*rockRange).rgb*0.6;
	vec3 sandColour = texture(sandTexture,UV*sandRange).rgb*0.6;
	vec3 snowColour = texture(snowTexture,UV*snowRange).rgb*0.8;
	
	// Mix the textures based on slope, height, and beach presence
	// Here, the base terrain is rock mixed with grass, but no grass where it cant grow (slopes)
    vec3 terrain_colour = mix(rockColour, grassColour, (1.0 - slope));
	
	// The next mix is getting the beach in (between the beach ranges)
    terrain_colour = mix(terrain_colour, sandColour, (1.0-beachMix)); 
	
	// The final mix is getting the snow in, depending on height      
    terrain_colour = mix(terrain_colour, snowColour, snowMix);
	
	ALBEDO = terrain_colour;
}
