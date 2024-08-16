shader_type spatial;
render_mode depth_prepass_alpha;
#include "mask_adjustment.gdshaderinc"

group_uniforms Material_Properties;
uniform float roughness : hint_range(0.0, 1.0, 0.01);
uniform vec2 uv_scale = vec2(1.0);

group_uniforms Textures;
group_uniforms Textures.Albedo;
uniform vec4 base_color : source_color = vec4(1.0);
uniform vec4 highlight_color : source_color = vec4(1.0);

group_uniforms Textures.Ambient_Occlusion;
uniform sampler2D ambient_occlusion : source_color;
uniform float ao_power : hint_range(0.0, 100.0, 0.1) = 1.0;
uniform float ao_adjust : hint_range(-5, 5, 0.1) = 0.0;

group_uniforms Textures.Normals;
uniform sampler2D normal : source_color;
uniform float normal_power : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float normal_adjust : hint_range(-5, 5, 0.1) = 0.0;

group_uniforms Textures.Edge_Wear;
uniform sampler2D edgewear : source_color;
uniform float edgewear_power : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float edgewear_adjust : hint_range(-5, 5, 0.1) = 0.0;

group_uniforms Textures.Grunge;
uniform sampler2D grunge_texture : source_color;
uniform vec4 grunge_color : source_color = vec4(1.0);
uniform float grunge_power : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float grunge_adjust : hint_range(-5, 5, 0.1) = 0.0;
uniform vec2 grunge_tile_size = vec2(1.0, 1.0);
group_uniforms;

void vertex() {

}

void fragment() {
	vec4 grunge_weight = vec4(0.0);
	if (grunge_power != 0.0){
		grunge_weight = get_mask_value(texture(grunge_texture, UV * uv_scale * grunge_tile_size), grunge_power, grunge_adjust);
	}
	vec4 base_grunge_color = mix(base_color, grunge_color, grunge_weight);

	vec4 edgewear_weight = get_mask_value(texture(edgewear, UV * uv_scale), edgewear_power, edgewear_adjust);
	vec4 fragment_color = mix(base_grunge_color, highlight_color, edgewear_weight);

	vec4 ao_weight = get_mask_value(texture(ambient_occlusion, UV * uv_scale), ao_power, ao_adjust);
	fragment_color *= ao_weight;

	vec4 normal_weight = get_mask_value(texture(normal, UV * uv_scale), normal_power, normal_adjust);

	ROUGHNESS = roughness;
	ALBEDO = fragment_color.rgb;
	ALPHA = fragment_color.a;
	NORMAL_MAP = normal_weight.rgb;
}
