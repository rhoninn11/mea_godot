shader_type spatial;

varying flat int instance_id;

void vertex() {
	// Called for every vertex the material is visible on.
	instance_id = INSTANCE_ID;
}

void fragment() {
	// Called for every pixel the material is visible on.
	int hmm = instance_id%2;
	if (hmm == 1) {
		ALBEDO = COLOR.rgb;
	} else {
		ALBEDO = vec3(0, 0, 0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
