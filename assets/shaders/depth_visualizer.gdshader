shader_type spatial;

render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

const float zNear = 100.0;
const float zFar = 1000.0;

void vertex() {
	POSITION = vec4(UV*2.0-1.0, 0.0, 1.0);
}
void fragment() {
	vec4 original = texture(SCREEN_TEXTURE, SCREEN_UV);
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	
	vec3 fog = vec3(0.0,0.0,0.0);
	
	float linear_depth = view.z;
	float scaled_depth = (zFar * zNear) / (zFar + (linear_depth * (zNear - zFar)));
	scaled_depth = clamp(scaled_depth, 0.0, 1.0);
	
	ALBEDO = mix(fog, original.rgb, scaled_depth);
	ALBEDO = original.rgb;
}
