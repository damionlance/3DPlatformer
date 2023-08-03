shader_type spatial;

uniform sampler2D tex_1_albedo : hint_default_white;
uniform sampler2D tex_2_albedo : hint_default_transparent;
uniform sampler2D tex_3_albedo : hint_default_transparent;
uniform sampler2D tex_4_albedo : hint_default_transparent;

void fragment() {
	float tex_2_blend_weight = COLOR.r;
	float tex_3_blend_weight = COLOR.g;
	float tex_4_blend_weight = COLOR.b;
	vec4 albedo1 = texture(tex_1_albedo, UV);
	vec4 albedo2 = texture(tex_2_albedo, UV);
	vec4 albedo3 = texture(tex_1_albedo, UV);
	vec4 albedo4 = texture(tex_2_albedo, UV);
	
	vec4 color = clamp(mix(albedo1, albedo2, tex_2_blend_weight), vec4(0.0), vec4(1.0));
	color = clamp(mix(color, albedo3, tex_3_blend_weight), vec4(0.0), vec4(1.0));
	color = clamp(mix(color, albedo4, tex_4_blend_weight), vec4(0.0), vec4(1.0));
	
	ALBEDO = color.rgb;
}
