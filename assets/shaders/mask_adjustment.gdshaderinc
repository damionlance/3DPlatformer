vec4 get_mask_value(vec4 mask_value, float mask_power, float mask_adjust){
	mask_value = pow(mask_value, vec4(mask_power));
	mask_value += mask_adjust;
	mask_value = clamp(mask_value, vec4(0.0), vec4(1.0));
	return mask_value;
}