shader_connection()

self.backdrop = instance_create_depth(x,y,depth+1,obj_angle_1_scene_1_backdrop)
self.foreground = instance_create_depth(x,y,depth-1,obj_angle_1_scene_1_foreground)
self.characters = instance_create_depth(x,y,depth-2,obj_angle_1_scene_1_characters)