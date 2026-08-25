shader_type spatial;

instance uniform float a = 0;
instance uniform float x0 = 0;
instance uniform float y0 = 0;
instance uniform float x1 = 0;
instance uniform float x2 = 0;

void vertex() {
	float s1 = a * sinh((x1 - x0) / a);
	float s2 = a * sinh((x2 - x0) / a);
	
	float s = s1 + (s2 - s1) * (UV.y * 2.0);
	float x = x0 + a * asinh(s/a);
	float caty = y0 + a * cosh((x - x0) / a);
	VERTEX += vec3(0,0,-caty);
}
void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
