shader_type spatial;

uniform sampler2D normalTex1;
uniform sampler2D normalTex2;


uniform vec2 wave_dir1 = vec2(1.0, 0.0);
uniform vec2 wave_dir2 = vec2(0.0, 1.0);

uniform float wave_speed : hint_range(0.0, 0.2) = 0.015;
uniform float roughness : hint_range(0.0, 1.0) = 0.05;

uniform float foam_range = 16.0;


uniform vec4 specularColour : hint_color = vec4(1.0, 1.0, 1.0, 0.26);
uniform vec4 baseColour : hint_color = vec4(0.18, 0.46, 0.45, 0.7);
uniform vec4 deepColour : hint_color = vec4(0.02, 0.18, 0.22, 0.95);
uniform vec4 foamColour : hint_color = vec4(1.0, 1.0, 1.0, 0.26);

varying vec3 eye_vec;
varying vec3 uv_world_pos;

vec3 getPosition(mat4 camera) {
	return (-camera[3] * camera).xyz;
	}


void vertex(){
	// Do some movement based on time
	VERTEX.y += (0.2*sin(VERTEX.x+3.0+TIME*2.0))+(0.1*sin(VERTEX.z+2.5+TIME*3.0));
	
	// used in normal mapping
	uv_world_pos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	vec3 cameraPosition = getPosition(INV_CAMERA_MATRIX).xyz;
	
	// for fresnel
	eye_vec = normalize(VERTEX - cameraPosition);
}

// Using Schlick's approximation
float fresnel(float cos_theta, float n1, float n2)
{
	float r_0 = pow((n1 - n2) / (n1 + n2), 2.0);
	return r_0 + (1.0 - r_0) * pow((1.0 - cos_theta), 5.0);
}

void fragment(){
	// Found on a couple shaders, seems to be a common usage
	// reference this
	// need to understand how this works
	vec4 depth_tex = texture(DEPTH_TEXTURE, SCREEN_UV) * 2.0 - 1.0;
	vec4 world_coord = INV_PROJECTION_MATRIX * vec4(SCREEN_UV, depth_tex.r, 1.0);
	world_coord.xyz /= world_coord.w;
	
	
	// Edge transparency and foam
	float edge_percentage = clamp(smoothstep(world_coord.z, world_coord.z+foam_range, VERTEX.z), 0.0, 1.0);

	
	vec2 normal_offset1 = (TIME * wave_dir1) * wave_speed;
	vec2 normal_offset2 = (TIME * wave_dir2) * wave_speed;

	vec3 normal_blend = mix(texture(normalTex1, uv_world_pos.xz / 32.0f + normal_offset1), texture(normalTex2, uv_world_pos.xz / 32.0f + normal_offset2), 0.5).rgb;
	normalize(normal_blend);

	
	float fres = fresnel(abs(dot(eye_vec, NORMAL)), 1.0, 1.33);
	
	vec4 combo = mix(baseColour,deepColour,0.8);
	vec3 foamMix = mix(foamColour.xyz,combo.xyz,edge_percentage);
	
	ALBEDO = mix(foamMix, specularColour.xyz, fres*specularColour.w);
	//ALBEDO = foamMix;
	ROUGHNESS = roughness;
	NORMALMAP = normal_blend;
	ALPHA = 0.95;
	// potential for depth alpha
}
