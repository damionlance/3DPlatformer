shader_type spatial;
render_mode diffuse_burley,specular_schlick_ggx;
uniform float speed = 1.0;
uniform vec2 layer_1_direction = vec2(1.0,0.0);
uniform vec2 layer_2_direction = vec2(0.5,1.5);

uniform sampler2D albedo_1 : hint_default_white;
uniform sampler2D albedo_2 : hint_default_white;

void fragment() {
	vec2 coord1 = vec2(UV.x + (TIME * layer_1_direction.x * speed) + sin(TIME), UV.y + (TIME * layer_1_direction.y * speed) + sin(TIME));
	vec2 coord2 = vec2(UV.x + (TIME * layer_2_direction.x * speed) + cos(TIME), UV.y + (TIME * layer_2_direction.y * speed) + sin(TIME));
	
	vec4 albedo_1_sample = texture(albedo_1, coord1);
	vec4 albedo_2_sample = texture(albedo_2, coord2);
	
	ALBEDO = mix(albedo_1_sample, albedo_2_sample, 0.5).rgb;
}

void light() {
	DIFFUSE_LIGHT = vec3(1.0,.5,0.0) * 2.0;
}
