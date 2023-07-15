shader_type spatial;

uniform sampler2D tex_1_albedo;
uniform sampler2D tex_2_albedo;

void fragment() {
	float blend_weight = COLOR.r;
	vec4 albedo1 = texture(tex_1_albedo, UV);
	vec4 albedo2 = texture(tex_2_albedo, UV);
	
	ALBEDO = clamp(mix(albedo1, albedo2, blend_weight).rgb, vec3(0.0), vec3(1.0));
}
