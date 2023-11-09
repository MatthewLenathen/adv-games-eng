shader_type spatial;

uniform sampler2D waterTexture;
uniform vec2 waterRange;

uniform sampler2D normalTex1;
uniform vec2 wave_dir1 = vec2(1.0, 0.0);
uniform sampler2D normalTex2;
uniform vec2 wave_dir2 = vec2(0.0, 1.0);
uniform float wave_speed : hint_range(0.0, 0.2) = 0.015;
varying vec3 uv_world_pos;
uniform float wave_scale : hint_range(0.0,100.0) = 4.0;

uniform vec4 tint_color : hint_color = vec4( 0.3, 0.4, 0.45, 1.0);

void vertex(){
	//VERTEX.y += -1.0+sin(TIME*0.01*VERTEX.x)+cos(TIME*0.01*VERTEX.z);
	//test
	VERTEX.y += (0.2*sin(VERTEX.x+3.0+TIME*2.0))+(0.1*sin(VERTEX.z+2.5+TIME*3.0));
	uv_world_pos = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

// Taken from https://godotshaders.com/snippet/fresnel/
float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

vec2 flipbook(vec2 uv, vec2 size, float progress){
	progress = floor( mod(progress, (size.x * size.y)) );
	vec2 frame_size = vec2(1.0, 1.0) / vec2(size.x, size.y);
	vec2 frame = fract(uv / size) + frame_size;
	
	frame.x += ( (progress / size.x) - frame_size.x * floor(progress/size.x) * size.x ) - frame_size.x;
	frame.y += (frame_size.y * floor(progress/size.x) ) - frame_size.y ;
	
	return frame;
}

void fragment(){
	vec2 test = SCREEN_UV;
	
	//vec3 colour = vec3(texture(waterTexture,UV*waterRange).rgb);
	
	
	vec3 base_color = vec3(0,0.2,1);
	vec3 deep_colour = vec3(0.0,0.0,0.5);
	float basic_fresnel = fresnel(5.0, NORMAL, VIEW);
	
	// trying flipbook stuff in this block
	/*
	vec2 flip_uv = flipbook(UV, vec2(3.0, 3.0), TIME * 10.);
	vec4 flip_texture = texture(waterTexture, flip_uv*waterRange);
	NORMAL = flip_texture.rgb;
	*/
	vec2 normal_offset1 = (TIME * wave_dir1) * wave_speed;
	vec2 normal_offset2 = (TIME * wave_dir2) * wave_speed;
	vec3 normal_blend = mix(texture(normalTex1, uv_world_pos.xz / wave_scale + normal_offset1), texture(normalTex2, uv_world_pos.xz / wave_scale + normal_offset2), 0.5).rgb;
	normalize(normal_blend);
	NORMAL = normal_blend;
	
	//basic_fresnel = fresnel(5.0, NORMAL, VIEW);
	
	vec3 combo = mix(base_color,deep_colour,0.9)+basic_fresnel;
	//ALBEDO = base_color + basic_fresnel;
	ALBEDO = combo;
	
	/*
	if(ALBEDO.r < 0.6 && ALBEDO.g <0.6 && ALBEDO.b<0.6)
	{
		ALPHA = 0.7;
	}else{ALPHA=0.9;}
	*/
	ALPHA = 0.95;
	
   
}
