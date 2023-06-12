shader_type spatial;
render_mode depth_prepass_alpha;
render_mode depth_test_disabled;

uniform float height_scale = 0.5;
uniform sampler2D noise;
uniform sampler2D normalmap;

varying vec2 tex_position;

void vertex() {
  VERTEX.xyz = VERTEX.xyz * .99f;
}

void fragment() {
  ALBEDO = vec3(0,0,0);
}