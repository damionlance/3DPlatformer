shader_type spatial;

uniform float scroll_speed : hint_range(0, 2) = 0.08;
uniform float scroll_speed2 : hint_range(0, 2) = 0.03;
uniform float angle_degrees : hint_range(0, 360) = 45.0;
uniform float texture_mix : hint_range(0, 1) = 0;
uniform float repeat_x : hint_range(1, 20) = 20;
uniform float repeat_y : hint_range(1, 20) = 12;
uniform float row_offset : hint_range(0, 1) = 1;
uniform sampler2D texture_to_scroll;
uniform sampler2D back_texture : hint_default_transparent;

void fragment() {
 float angle_rad = radians(angle_degrees);

 vec2 direction = vec2(cos(angle_rad), sin(angle_rad));
 vec2 direction2 = -direction;

 vec2 offset_uv = UV - (TIME * scroll_speed * direction);
 vec2 offset_uv2 = UV - (TIME * scroll_speed2 * direction2);

 float offset = fract(floor(offset_uv.y * repeat_y) * 0.5) > 0.0 ? (row_offset * 0.324) : 0.0;
 float offset2 = fract(floor(offset_uv2.y * repeat_y) * 0.5) > 0.0 ? (row_offset * 0.324) : 0.0;

 offset_uv.x += offset;
 offset_uv2.x += offset2;

offset_uv2.y += .01*sin(TIME);
offset_uv2.x += .25*sin(TIME) * (.5*UV.y);

 vec2 scaled_uv = vec2(fract(offset_uv.x * repeat_x), 
              fract(offset_uv.y * repeat_y));
vec2 scaled_uv2 = vec2(fract(offset_uv2.x * repeat_x), 
              fract(offset_uv2.y * repeat_y));

 vec2 texelSize = vec2(1.0) / vec2(textureSize(texture_to_scroll, 0));
 vec2 snappedUV = round(scaled_uv / texelSize) * texelSize;
vec2 snappedUV2 = round(scaled_uv2 / texelSize) * texelSize;

vec4 texture1_sample = texture(texture_to_scroll, snappedUV);
vec4 texture2_sample = texture(back_texture, snappedUV2);
vec3 clamped_albedo = vec3(0.0);

clamped_albedo.r = clamp(texture1_sample.r + texture2_sample.r, 0.0, 1.0);
clamped_albedo.g = clamp(texture1_sample.g + texture2_sample.g, 0.0, 1.0);
clamped_albedo.b = clamp(texture1_sample.b + texture2_sample.b, 0.0, 1.0);

ALBEDO = clamped_albedo;
//ALPHA = 1.0 * float((bool(texture1_sample.a) || bool(texture2_sample.a))) * mix(texture1_sample, texture2_sample, texture_mix).a;
ALPHA = clamp(texture1_sample.a + texture2_sample.a, 0.0, 1.0);
}