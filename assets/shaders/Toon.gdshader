shader_type spatial;
render_mode cull_disabled;

uniform sampler2D image_texture: hint_screen;
uniform sampler2D toon_ramp: hint_albedo ;
uniform float rim_power: hint_range(1,100) = 1.0;
uniform float rim_size: hint_range(0,1) = 0.3;

void fragment() {
	vec4 color = texture(image_texture, UV);
	ALBEDO = color.rgb;
	ALPHA = color.a;
	ALPHA_SCISSOR = pow(0.1, color.a);
}

void light() {
	float shadow = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	float rim = (shadow * (clamp(dot(NORMAL, VIEW), 0.0, 1.0) < rim_size ? 1.0 : 0.0)) ;

	vec4 processed_shadow = texture(toon_ramp, ((shadow * ATTENUATION)).xy);
	
	DIFFUSE_LIGHT += (processed_shadow.rgb + (rim*rim_power)) * ALBEDO  * LIGHT_COLOR;
}