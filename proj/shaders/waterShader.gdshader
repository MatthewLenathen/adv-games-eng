shader_type spatial;

uniform sampler2D waterTexture;

uniform vec2 waterRange;


void fragment(){

vec3 colour = vec3(texture(waterTexture,UV*waterRange).rgb);
    ALBEDO = colour;
}
