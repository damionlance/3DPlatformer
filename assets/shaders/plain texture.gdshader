shader_type spatial;

uniform sampler2D image : hint_default_transparent;

void fragment() {
	vec4 sample = texture(image, UV);
	
	ALBEDO = sample.rgb;
}
