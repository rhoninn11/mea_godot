shader_type spatial;

uniform int hmm = 2;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	if (hmm == 1) {
		ALBEDO = vec3(1, 0, 0);
	} else {
		ALBEDO = vec3(0, 1, 0);
	}
		
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
