shader_type spatial;
render_mode depth_prepass_alpha;
#include "mask_adjustment.gdshaderinc"

group_uniforms Material_Properties;
uniform float roughness : hint_range(0.0, 1.0, 0.01);
uniform float UV_Scaling : hint_range(.1, 4.0, 0.1) = 1.0;

group_uniforms Textures;
group_uniforms Textures.Albedo;
uniform vec4 base_color_1 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 highlight_color_1 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 base_color_2 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 highlight_color_2 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 base_color_3 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 highlight_color_3 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 base_color_4 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 highlight_color_4 : source_color = vec4(0.0, 0.0, 0.0, 1.0);

group_uniforms Textures.Ambient_Occlusion;
uniform sampler2D ambient_occlusion_1 : source_color;
uniform float ao_power_1 : hint_range(0.0, 100.0, 0.1) = 1.0;
uniform float ao_adjust_1 : hint_range(-5, 5, 0.1) = 0.0;
uniform sampler2D ambient_occlusion_2 : source_color;
uniform float ao_power_2 : hint_range(0.0, 100.0, 0.1) = 1.0;
uniform float ao_adjust_2 : hint_range(-5, 5, 0.1) = 0.0;
uniform sampler2D ambient_occlusion_3 : source_color;
uniform float ao_power_3 : hint_range(0.0, 100.0, 0.1) = 1.0;
uniform float ao_adjust_3 : hint_range(-5, 5, 0.1) = 0.0;
uniform sampler2D ambient_occlusion_4 : source_color;
uniform float ao_power_4 : hint_range(0.0, 100.0, 0.1) = 1.0;
uniform float ao_adjust_4 : hint_range(-5, 5, 0.1) = 0.0;

group_uniforms Textures.Normals;
uniform sampler2D normal_1 : source_color;
uniform float normal_power_1 : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float normal_adjust_1 : hint_range(-5, 5, 0.1) = 0.0;
uniform sampler2D normal_2 : source_color;
uniform float normal_power_2 : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float normal_adjust_2 : hint_range(-5, 5, 0.1) = 0.0;
uniform sampler2D normal_3 : source_color;
uniform float normal_power_3 : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float normal_adjust_3 : hint_range(-5, 5, 0.1) = 0.0;
uniform sampler2D normal_4 : source_color;
uniform float normal_power_4 : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float normal_adjust_4 : hint_range(-5, 5, 0.1) = 0.0;

group_uniforms Textures.Edge_Wear;
uniform sampler2D edgewear_1 : source_color;
uniform float edgewear_power_1 : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float edgewear_adjust_1 : hint_range(-5, 5, 0.1) = 0.0;
uniform sampler2D edgewear_2 : source_color;
uniform float edgewear_power_2 : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float edgewear_adjust_2 : hint_range(-5, 5, 0.1) = 0.0;
uniform sampler2D edgewear_3 : source_color;
uniform float edgewear_power_3 : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float edgewear_adjust_3 : hint_range(-5, 5, 0.1) = 0.0;
uniform sampler2D edgewear_4 : source_color;
uniform float edgewear_power_4 : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float edgewear_adjust_4 : hint_range(-5, 5, 0.1) = 0.0;

group_uniforms Textures.Grunge;
uniform sampler2D grunge_texture_1 : source_color;
uniform vec4 grunge_color_1 : source_color = vec4(0.0);
uniform float grunge_power_1 : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float grunge_adjust_1 : hint_range(-5, 5, 0.1) = 0.0;
uniform vec2 grunge_tile_size_1 = vec2(1.0, 1.0);
uniform sampler2D grunge_texture_2 : source_color;
uniform vec4 grunge_color_2 : source_color = vec4(0.0);
uniform float grunge_power_2 : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float grunge_adjust_2 : hint_range(-5, 5, 0.1) = 0.0;
uniform vec2 grunge_tile_size_2 = vec2(1.0, 1.0);
uniform sampler2D grunge_texture_3 : source_color;
uniform vec4 grunge_color_3 : source_color = vec4(0.0);
uniform float grunge_power_3 : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float grunge_adjust_3 : hint_range(-5, 5, 0.1) = 0.0;
uniform vec2 grunge_tile_size_3 = vec2(1.0, 1.0);
uniform sampler2D grunge_texture_4 : source_color;
uniform vec4 grunge_color_4 : source_color = vec4(0.0);
uniform float grunge_power_4 : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float grunge_adjust_4 : hint_range(-5, 5, 0.1) = 0.0;
uniform vec2 grunge_tile_size_4 = vec2(1.0, 1.0);
group_uniforms Textures.Emission;
uniform sampler2D emission_map : source_color;
uniform vec2 emission_scroll = vec2(0.0, 0.0);
uniform vec2 emission_scale = vec2(1.0, 1.0);
uniform vec4 emission_color : source_color = vec4(1.0);
uniform float emission_power : hint_range(0.0, 2.0, .1) = 1.0;
uniform float emission_adjust : hint_range(-5.0, 5.0, 0.1) = 0.0;

group_uniforms;

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}


void fragment() {
	vec4 grunge_weight_1 = get_mask_value(texture(grunge_texture_1, UV * grunge_tile_size_1 * UV_Scaling), grunge_power_1, grunge_adjust_1);
	vec4 base_grunge_color_1 = mix(base_color_1, grunge_color_1, grunge_weight_1);
	vec4 grunge_weight_2 = get_mask_value(texture(grunge_texture_2, UV * grunge_tile_size_2 * UV_Scaling), grunge_power_2, grunge_adjust_2);
	vec4 base_grunge_color_2 = mix(base_color_2, grunge_color_2, grunge_weight_2);
	vec4 grunge_weight_3 = get_mask_value(texture(grunge_texture_3, UV * grunge_tile_size_3 * UV_Scaling), grunge_power_3, grunge_adjust_3);
	vec4 base_grunge_color_3 = mix(base_color_3, grunge_color_3, grunge_weight_3);
	vec4 grunge_weight_4 = get_mask_value(texture(grunge_texture_4, UV * grunge_tile_size_4 * UV_Scaling), grunge_power_4, grunge_adjust_4);
	vec4 base_grunge_color_4 = mix(base_color_4, grunge_color_4, grunge_weight_4);
	
	vec4 edgewear_weight_1 = get_mask_value(texture(edgewear_1, UV * UV_Scaling), edgewear_power_1, edgewear_adjust_1);
	vec4 fragment_color_1 = mix(base_grunge_color_1, highlight_color_1, edgewear_weight_1);
	vec4 edgewear_weight_2 = get_mask_value(texture(edgewear_2, UV * UV_Scaling), edgewear_power_2, edgewear_adjust_2);
	vec4 fragment_color_2 = mix(base_grunge_color_2, highlight_color_2, edgewear_weight_2);
	vec4 edgewear_weight_3 = get_mask_value(texture(edgewear_3, UV * UV_Scaling), edgewear_power_3, edgewear_adjust_3);
	vec4 fragment_color_3 = mix(base_grunge_color_3, highlight_color_3, edgewear_weight_3);
	vec4 edgewear_weight_4 = get_mask_value(texture(edgewear_4, UV * UV_Scaling), edgewear_power_4, edgewear_adjust_4);
	vec4 fragment_color_4 = mix(base_grunge_color_4, highlight_color_4, edgewear_weight_4);
	
	vec4 ao_weight_1 = get_mask_value(texture(ambient_occlusion_1, UV * UV_Scaling), ao_power_1, ao_adjust_1);
	fragment_color_1 *= ao_weight_1;
	vec4 ao_weight_2 = get_mask_value(texture(ambient_occlusion_2, UV * UV_Scaling), ao_power_2, ao_adjust_2);
	fragment_color_2 *= ao_weight_2;
	vec4 ao_weight_3 = get_mask_value(texture(ambient_occlusion_3, UV * UV_Scaling), ao_power_3, ao_adjust_3);
	fragment_color_3 *= ao_weight_3;
	vec4 ao_weight_4 = get_mask_value(texture(ambient_occlusion_4, UV * UV_Scaling), ao_power_4, ao_adjust_4);
	fragment_color_4 *= ao_weight_4;
	
	vec4 normal_weight_1 = get_mask_value(texture(normal_1, UV * UV_Scaling), normal_power_1, normal_adjust_1);
	vec4 normal_weight_2 = get_mask_value(texture(normal_2, UV * UV_Scaling), normal_power_2, normal_adjust_2);
	vec4 normal_weight_3 = get_mask_value(texture(normal_3, UV * UV_Scaling), normal_power_3, normal_adjust_3);
	vec4 normal_weight_4 = get_mask_value(texture(normal_4, UV * UV_Scaling), normal_power_4, normal_adjust_4);
	
	vec4 final_color = clamp(mix(fragment_color_1, fragment_color_2, COLOR.r), vec4(0.0), vec4(1.0));
	final_color = clamp(mix( final_color, fragment_color_3, COLOR.g), vec4(0.0), vec4(1.0));
	final_color = clamp(mix(final_color, fragment_color_4, COLOR.b), vec4(0.0), vec4(1.0));
	
	vec4 final_normal = normal_weight_1 + normal_weight_2 + normal_weight_3 + normal_weight_4;
	
	vec4 emission_strength = get_mask_value(texture(emission_map, (world_pos/emission_scale) + emission_scroll * (TIME/5.0)), emission_power, emission_adjust);
	
	EMISSION = (clamp(final_color.rgb + (emission_color.rgb), 0.0, 1.0) * emission_strength.rgb) * emission_color.a;
	ROUGHNESS = roughness;
	ALBEDO = final_color.rgb;
	NORMAL_MAP = final_normal.rgb;
}

