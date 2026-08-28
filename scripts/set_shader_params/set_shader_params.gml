function shader_connection(){
	global.uniform_time_milli_void = shader_get_uniform(sh_static_shadows, "u_time_milli")
	global.uniform_void_mix_with_sprite = shader_get_uniform(sh_static_shadows, "u_mix_with_sprite")
	global.uniform_alpha_mix_void = shader_get_uniform(sh_static_shadows, "u_alpha_mix")
	global.uniform_feather_proportion_void = shader_get_uniform(sh_static_shadows, "u_featherProportion")
	global.uniform_ignore_gray_void = shader_get_uniform(sh_static_shadows, "u_ignoreGray")
	//global.uniform_void_tile_size = shader_get_uniform(sh_void, "u_tileSize")
	//global.sampler_index_void_texture = shader_get_sampler_index(sh_void, "s_voidTexture")
	//global.void_texture = sprite_get_texture(spr_void_texture, 0)
	
	
	//global.uniform_time_milli_void_ground = shader_get_uniform(sh_void_ground, "u_time_milli")
	
}

function set_void_shader_params(_alpha_mix = 1, _mix_with_sprite = false, 
	_ignore_gray = false ,_feather_prop = 0, _time = current_time) {
	
	
	shader_set_uniform_f(global.uniform_time_milli_void, _time)
	shader_set_uniform_f(global.uniform_void_mix_with_sprite, _mix_with_sprite)
	shader_set_uniform_f(global.uniform_alpha_mix_void, _alpha_mix)
	shader_set_uniform_f(global.uniform_feather_proportion_void, _feather_prop)
	shader_set_uniform_f(global.uniform_ignore_gray_void, _ignore_gray)

	
}