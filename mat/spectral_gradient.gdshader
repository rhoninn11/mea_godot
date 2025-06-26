shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(UV.x,UV.y,0.5);

	// uv range for x is 0.0-1.0 but for y is 0.5-1.0
	//float spread = UV.x * 0.1 + 0.05;
	float spread = 0.05;
	float base = UV.y;
	vec3 val = vec3(base-spread, base, base+spread) * TAU;
	vec3 wave = (-cos(val) + 1.0)*0.5-0.5;
	ALBEDO = vec3(wave);

	//if (base > 0.49) {
		//ALBEDO = vec3(1,0,0);
	//}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
