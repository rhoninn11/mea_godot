shader_type spatial;

uniform int hand = 2;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	if (hand == 1) {
		ALBEDO = vec3(0, 0, 1);
	} else {
		ALBEDO = vec3(1, 0, 0);
	}

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
