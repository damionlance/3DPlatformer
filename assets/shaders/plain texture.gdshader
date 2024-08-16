shader_type spatial;

uniform sampler2D image : source_color;

void fragment() {
	vec4 sample = texture(image, UV);

	ALBEDO = sample.rgb;
}
