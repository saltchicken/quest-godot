shader_type spatial;

uniform vec3 ocean_floor_color : source_color = vec3(0.01, 0.2, 1.0);

void fragment() {
  ALBEDO = ocean_floor_color;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
