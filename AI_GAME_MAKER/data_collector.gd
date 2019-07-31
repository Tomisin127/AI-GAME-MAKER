""" ARCHITECTURE OF THIS PROJECT """
"""  -WE START BY CREATING A LIST OF OBJECT
     -WE THEN CREATE A COPIES OF THOSE OBJECT
	 -THE COPIES WILL BE USED IN MANIPULATION
	 -THEN WE GIVE THE COPIES SOME PROPERTIES BASED ON THERE TYPE
	 -FINALLY, WE ADD SOME COOL STUFFS
"""

"""The long term aim of this project is to make it almost impossible for the user to code the basic stuff
and even advance stuffs, we make use of the inspector bar as a way to interact with the code,
the only downside is that the inspector bar will grow in size but if there is a way to solve that,
its highly welcomed

also the other goals of this project is to make reuseability possible with every new and existing project
and also to maintain all the codes in just one script

This program is free and open source ,this means it can be used in existing
projects..... improvements and additions are welcome :) 

WHAT IF WE COULD EDIT THE GAME AS IT IS RUNNING, I DONT MEAN COMING BACK TO THE CODE WHILE GAME IS RUNNING,
I MEAN EDITTING THE GAME AS IT IS RUNNING ON THE INTERFACE FROM THE GAME INTERFACE
THEN IT RETAINS THE PROPERTIES THAT WAS CHANGED WHEN IT RUNS AGAIN

NOTE - this script or scene as not been tested with autoload, some features are also yet to be fully developed and may be buggy 
     - BALL NODE AND LABEL NODE IN THE SCENE TREE IS OPTIONAL ( YOU CAN REMOVE IT )
	 - DO NOT REMOVE THE LINE2D NODE"""

#DO NOT UNCOMMENT ANY  CODE COMMENT OR DELETE ANY CODE COMMENT
#DOING THIS CAN BREAK THE CODE OR GET YOU SOME INSPIRATION FROM COMMENTS, LOL

tool

extends Node

#all lines variable
onready var a
onready var line_name
onready var line

#export (NodePath) var test

export(Array,Image) var sprites

export(PoolVector2Array) var position

export(PoolIntArray) var rotation

export(PoolVector2Array) var scale

export(PoolVector2Array) var size

export(PoolVector2Array) var copies_position
export(PoolIntArray) var copies_rotation
export(PoolVector2Array) var copies_scale

var screensize

#holds the sprites
var list_of_sprites = []

#holds the object created such as rigid_body, static_body
var list_of_objects = []

#holds the copies of objects, this list very essential 
#to the development of this tool
var list_of_copies =[]

#holds the normal of the length of the copies 
var copies_normal_array =[]

#holds the normal of the length of the copies,but with additional
#push_back(vector2(0,0) at the end of this list
var fake_copies_normal_array =[]

#check if sprite is created
var is_sprite_created =false

#export(int)var speed
#export(PoolIntArray) var constant_rotation_speed

#pick object to rotate
export(int)var pick_rotated_object

#collects information of the data created
export (PoolStringArray) var body_type
export(PoolStringArray) var collision_type
export(PoolIntArray) var object_index

#specifies which object to be selected(0,1) 0-first object, 1-second object
export(int) var object_array_num

#toggle to enable creation of copies
export(bool) var enable_create_copy

#number of copies to be created, this will make use of (var) object_array_num
#to determine type of copies to be made
export(int) var number_of_copies

onready var rigidbody = RigidBody2D.new()
onready var staticbody = StaticBody2D.new()

#store data information in a dict
onready var details_dictionary = {}

#all properties of rigid body 2d
var is_rigid_body_properties_showing=false
export (PoolIntArray) var mass
export (PoolIntArray) var weight
export (PoolIntArray)var gravity_scale
export (bool)var custom_integration
export(bool) var contact_monitor
export(bool) var sleeping
export(bool) var can_sleep
export(PoolIntArray) var linear_damp
export(PoolVector2Array)var linear_velocity
export(PoolIntArray)var angular_velocity
export(PoolIntArray)var angular_damp
export(PoolVector2Array) var applied_force
export(PoolIntArray)var applied_torque

#toggle to make use of line to draw data
export(bool) var enable_line_edit

#show the line 2d
export(bool) var show_line

#when the object is on a point in a line,it can rotate to face the angle
#where the line is facing
export(bool) var object_rotate_to_line_angle

#store the result of subtraction of copies_normal_array - fake_copies_normal array
var traverse_vector_array = []

export (int) var pick_index
export (PoolVector2Array) var shift_vector

export (int) var point_edit_index

export(bool) var enable_line_collision

#toggle to use a new way to arrangement objects without line method
export(bool) var is_using_L_arrangement

onready var image_copies_container = Node.new()

#a list that stores seperate objects of two distinct types
# for example combines rigid and static bodies on the same line inside this list
var list_of_coexistence =[]

#coexistence by value(ordinary coexistence
export (PoolIntArray) var initial_object_to_coexist
export (PoolIntArray) var point_to_coexist

var time=0
var f =0

#coexistence by data
export(PoolIntArray) var old_pos_in_list
export(PoolIntArray) var object_number

var data_coexistence_happened:bool
export (int) var data_coexistence_selector

func _ready():
#this code is super useful because no matter how you move a node(LINE2D) in the scene
#tree, the position of the node is tracked and in turn the name is gotten
#the only problem we may encounter is if we add another line2D to the scene tree

	for i in range(0,get_children().size()):
		if (get_children()[i] is Line2D):
			a = get_children()[i]
			line_name = a.name # [for i in range(10) if get_children()[i] is Line2D else null]
			line = get_node("/root/data/%s"% str(line_name))
			
			
			
	
	screensize = get_viewport().get_visible_rect().size
	
	#create the first set of objects
	spawn_initial_object(sprites,body_type,collision_type,object_index)
	
	spawn_more_of_one_version(object_array_num,enable_create_copy,number_of_copies)
	
	#ordinary coexistence, the values passed in code should be on the inspector bar
	#coexistence(point_to_coexist,true)
	
	line_mapping(show_line,enable_line_edit,object_rotate_to_line_angle)
	
	
	#traverse_each_copy(pick_index , shift_vector)
	
	#the values passed to this function should be passed directly from the inspector bar
	#putting this function in process does almost the same work
	coexistence_by_data(list_of_copies[data_coexistence_selector],old_pos_in_list,object_number)
	
	#line_collision(enable_line_collision)
	
	pass
	
func _process(delta):
	#function in process,make sure you remove the version in ready function
	#coexistence_by_data(list_of_copies[data_coexistence_selector],old_pos_in_list,object_number)
	
	L_shape_arrangement(is_using_L_arrangement,delta)
	#coexistence(1)
	
	print(details_dictionary)
	
	copies_normal_vector()
	
	line_mapping(show_line,enable_line_edit,object_rotate_to_line_angle)
	
	rigid_body_properties(mass,weight,gravity_scale,custom_integration,contact_monitor,sleeping,can_sleep,linear_damp,linear_velocity,angular_velocity, angular_damp, applied_force,applied_torque)
	
	movement_control()
	
	properties_of_copies()
	
	line_vector_edit(point_edit_index)
	
	#linear_transformation(linear_velocity,speed,delta)
	
	#constant_rotation(pick_rotated_object,constant_rotation_speed,delta)
	#print("copies normal array: ", copies_normal_array)
	#print("traverse vector array: ", traverse_vector_array)
	
	
	
	pass
	
	#create set of objects, accepts image, body_type,collision_type, index respectively in the inspector bar
func spawn_initial_object(image_array, b ,collision ,object_index):
	
	#since we are loading array of images, we do this
	for i in range(image_array.size()):
		
		var create_sprite = Sprite.new()
		
		var load_path_images = load(image_array[i].get_load_path()).resource_path
		
		create_sprite.texture = load(load_path_images)
		
		
		#if object created was rigid body
		#more object type can be added by you :)
		if b[i] == "rigidbody2d":
			
			add_child(rigidbody)
			rigidbody.add_child(create_sprite)
			var col= CollisionShape2D.new()
			rigidbody.add_child(col)
			is_sprite_created =true
			
			#if object collision type was rigidbody
			#more collision type can be added by you :)
			
			if collision[i] == "boxshape":
				for i in range(0,image_array.size()-1):
					var box = RectangleShape2D.new()
					#col.add_child(box)
					box.extents = create_sprite.scale
					col.shape= box
					
					rigidbody.add_child(col)
					list_of_objects.append(rigidbody)
					
					#box.extents =Vector2(list_of_sprites[i].scale.x,list_of_sprites[i].scale.y)
					#print(box.extents)
					
					
		
		#if the object created was staticbody
		#more object type can be added by you :)
		elif b[i] == "staticbody2d":
			
			add_child(staticbody)
			staticbody.add_child(create_sprite)
			var col= CollisionShape2D.new()
			staticbody.add_child(col)
			is_sprite_created =true
			
			#if the collision type was boxshape
			#more collision type can be added by you :)
			if collision[i] == "boxshape":
				for i in range(0,image_array.size()-1):
					var box = RectangleShape2D.new()
					#col.add_child(box)
					box.extents = create_sprite.scale
					col.shape= box
					
					staticbody.add_child(col)
					list_of_objects.append(staticbody)
					#box.extents =Vector2(list_of_sprites[i].scale.x,list_of_sprites[i].scale.y)
					#print(box.extents)
		
		#add all the created sprite in the sprite list
		list_of_sprites.append(create_sprite) 
		
		#we are hiding the inital sprite that was created for the objects
		#since we will be making use of copies of object
		#there can be a more creative solution from you :)
		create_sprite.hide()
		
		#add the details in the dictionary 
		details_dictionary= {"texture": sprites, "body":body_type , "collision": collision_type, "index":object_index}
		
		#print(list_of_sprites)
		
	
	pass
	
	#this is probably not really needed since we will be making use of 
	#list of copies rather than list of objects
func movement_control():
	
	if is_sprite_created==true:
		for i in range(sprites.size()):
			#making sure that the size of the copies array is equal to other properties
			#this is very important for uniformity, although it can be bypassed by coding
			#a different algorithm(just an idea)
			if sprites.size() == position.size() and sprites.size() == rotation.size() and sprites.size() == scale.size():
				list_of_objects[i].position =position[i] #user input position from inspector bar
				list_of_objects[i].rotation = rotation[i]
				list_of_objects[i].scale = scale[i]
#				list_of_objects[i].size = size[i]

			else:
				print("ERROR-set the same size as sprite created")
				#quit the program if not the same size(lack of uniformity)
				#get_tree().quit()
				
	pass
	
	#this is the important stuff(the copies are what we will make use of
func properties_of_copies():
	for i in range(0, list_of_copies.size()):
		list_of_copies[i].position += copies_position[i]
		list_of_copies[i].rotation += copies_rotation[i]
		list_of_copies[i].scale = copies_scale[i]
		

#NOT USEFUL , BUT DONT CLEAR THEM, COMMENTED CODES CAN BE INSPIRING
#func linear_transformation(linear_velocity, speed, delta):
#
#	if is_sprite_created==true and sprites.size() ==linear_velocity.size():
#		for i in range(0,sprites.size()):
#			list_of_sprites[i].position +=linear_velocity[i] *speed *delta
#			list_of_sprites[i].set_position(list_of_sprites[i].position)
#
#	pass

#func constant_rotation(pick_object ,crspeed, change):
#	if is_sprite_created==true:
#		list_of_sprites[pick_object].rotate(crspeed[pick_object] * PI *change)
#		#list_of_sprites[pick_object].rotation += crspeed[pick_object] *PI *change
#





# this is the function that handles the spawning of copies,you may be wondering why i created
# the (spawn initial function) i too wonder, but we still made use of some information from the previous func
#such as [details_dictionary]

# accepts the index to be duplicated, boolean, number of copies
func spawn_more_of_one_version(pick_object,boolean, copies):
	if boolean ==true and is_sprite_created==true:
		#for i in range(0,sprites.size()):
		
		add_child(image_copies_container)
		
		#print(details_dictionary.get("index")[pick_object])
		for r in range(copies):
			#randomize()
			#list_of_sprites[pick_object]
			
			#get index of the object in dict and compare it with the index that was givern by user
			#same for body type, then create the copies
			if details_dictionary.get("index")[pick_object] == pick_object:
				if details_dictionary.get("body")[pick_object]=="rigidbody2d":
					var box_shape = RectangleShape2D.new()
					
					var r_copy = RigidBody2D.new()
					var s_copy = Sprite.new()
					
					var load_path_images = load(sprites[pick_object].get_load_path()).resource_path
					s_copy.texture = load(load_path_images)
					
					var c_copy = CollisionShape2D.new()
					box_shape.extents = s_copy.get_rect().size
					c_copy.shape = box_shape
					
					image_copies_container.add_child(r_copy)
					r_copy.add_child(s_copy)
					r_copy.add_child(c_copy)
					#randomize()
					
					#finally add the copies to list of copies array
					list_of_copies.append(r_copy)
					#print(list_of_copies)
					#list_of_copies[r].position = Vector2(rand_range(0,1000),rand_range(0,1000))
					#print(image_copies_container.get_children())
					is_rigid_body_properties_showing =true
					
					#do the same for staticbody2d
			if details_dictionary.get("index")[pick_object]==pick_object:
				if details_dictionary.get("body")[pick_object] =="staticbody2d":
					var box_shape = RectangleShape2D.new()
					var static_copy = StaticBody2D.new()
					var sprite_copy = Sprite.new()
					
					var load_path_images = load(sprites[pick_object].get_load_path()).resource_path
					sprite_copy.texture = load(load_path_images)
					
					var c_copy = CollisionShape2D.new()
					box_shape.extents = sprite_copy.get_rect().size
					c_copy.shape = box_shape
					
					image_copies_container.add_child(static_copy)
					static_copy.add_child(sprite_copy)
					static_copy.add_child(c_copy)
					
					#finally add the new copies to list of copies array
					list_of_copies.append(static_copy)
					
					
					
					
		pass
	pass
	
	
	#the rigid body properties , same as the built in rigid body
func rigid_body_properties(mass, weight,gravity_scale, custom_integ,contact_monitor,sleeping,can_sleep,linear_damp,linear_velocity,angular_velocity, angular_damp, applied_force,applied_torque):
	#properties of all the copies of rigidbody
	for v in range(list_of_copies.size()):
		#print(v)
		if is_rigid_body_properties_showing==true:
			
			if list_of_copies[v] is RigidBody2D and mass.size()==number_of_copies: #notice the uniformity between mass size and number of copies
				
				
				list_of_copies[v].mass = mass[v]
				list_of_copies[v].weight = weight[v]
				list_of_copies[v].gravity_scale= float(gravity_scale[v])
				list_of_copies[v].custom_integrator = custom_integ
				list_of_copies[v].contact_monitor = contact_monitor
				list_of_copies[v].linear_damp = linear_damp[v]
				list_of_copies[v].sleeping = sleeping
				list_of_copies[v].can_sleep = can_sleep
				list_of_copies[v].linear_velocity = linear_velocity[v]
				list_of_copies[v].angular_velocity = angular_velocity[v]
				list_of_copies[v].angular_damp = angular_damp[v]
				list_of_copies[v].applied_force= applied_force[v]
				list_of_copies[v].applied_torque = applied_torque[v]
			#else:
				#quit the program if there is no uniformity
				#get_tree().quit()
		
		
		pass
		
	#this function accepts, a boolean to show the line of the line method
	#enable_line variable accepts boolean, so as not to interfare with L SHAPE ARRANGEMENT
	#there can a coexistence of LINE MAPPING AND L SHAPE ARRANGEMENT(just an idea)
	#then finally accepts ability to rotate copies on the line according to the angle of the line
func line_mapping(show_line,enable_line, rotate_to_line_angle):
	
	var null_position
	
	if show_line==false:
		line.hide()
		
	if enable_line == true and is_sprite_created==true and show_line==true:
		var point_count = line.get_point_count()
		#print("point_count: ",point_count)
		var point_position = line.get_points()
		#print("point position: ", point_position)
		
		for i in range(0,list_of_copies.size()):
			#find if a position is null in the list of copies
			#i am not sure if this is useful yet
			null_position = list_of_copies.find(null)
			
			#if data_coexistence_happened==true:
				#for p in range(0,list_of_copies.size()):
					#list_of_copies[data_coexistence_selector].position = point_position[old_pos_in_list[data_coexistence_selector]]
			
			#set the position of the copies in the list to each point on the line respectively
			#you could do something like interchanging copies on different point
			#instead of using traverse vector array(using normal) to move a different point in space
			list_of_copies[i].position = point_position[i] 
			
			#append to copies normal array and fake copies normal array
			# it will be useful in calculations onf the traverse vector array
			copies_normal_array.append(list_of_copies[i].position)
			fake_copies_normal_array.append(list_of_copies[i].position)
			
			#since this function will be called in process , the list will become big
			#so when it gets to the size of the list of copies array, then we clear the list
			#then remember the above code will append to the list again and the cycle continues
			if copies_normal_array.size() > list_of_copies.size():
				copies_normal_array.clear()
				
			if fake_copies_normal_array.size() > list_of_copies.size():
				fake_copies_normal_array.clear()
				
			#this is just to know if the points are on the line position
			if list_of_copies[i].position != point_position[i]:
				print("i am not in position")
				#list_of_copies[i].position = point_position[i]
			#point_position[0] + list_of_copies[i].position
			
			#rotate the copies of object to the angle where the point is facing
			if object_rotate_to_line_angle ==true:
				list_of_copies[i].rotate(point_position[i].angle())
				
				for i in range(0,sprites.size()):
					if details_dictionary.get("body")[i] == "staticbody2d":
						print("asdhjdskjkjdskjsdjkd")
						object_rotate_to_line_angle=false
				
		
		#push back an extra vector2 to the end of the fake copies normal array
		#because this will be needed when we are subtracting from copies normal array
		fake_copies_normal_array.push_back(Vector2(0,0))
		
		for t in range(0,list_of_copies.size()-1):
			#subtract(at t=0) copies normal array from(at t=1) fake copies normal array
			#this is because t will increase to about 4 for copies normal array
			#and t at 4 needs to subtract from fake copies normal array(t+1 which is 4+1)
			#thats the essence of pushing a vector2(0,0) to fake copies normal array
			# so that there will be something to subtract from in the end 
			var p = copies_normal_array[t] - fake_copies_normal_array[t+1]
			
			#then append it to traverse vector array
			traverse_vector_array.append(p)
			
			#clear the traverse vector array when it get to the end,remember the previous explanation
		if traverse_vector_array.size() > list_of_copies.size():
			traverse_vector_array.clear()
			
#	if list_of_copies.has(null):
#		print("i have null")
#		coexistence(null_position,true)
#
#	if not list_of_copies.has(null):
#		coexistence(null_position, false)
#
#		print("null position : ", null_position)

	pass
	
	
	#feature under construction , not to be used as it is buggy
	#the idea behind this function is to create a staticbody on the gaps
	#of the difference between point a and b on the line arrangement method(thats if point a and b are not close together)
	#its crazy but possible
	#this function accepts a boolean to toggle activation 
func line_collision(enable_line_collision):
	if enable_line_collision ==true and is_sprite_created ==true:
		for i in range(0,list_of_copies.size()):
			var static_body = StaticBody2D.new()
			var collision = CollisionShape2D.new()
			line.add_child(static_body)
			
			var rectangle_collision = RectangleShape2D.new()
			
			rectangle_collision.extents = (Vector2(traverse_vector_array[i-1].x,traverse_vector_array[i-1].y).normalized()) +Vector2(10,40)
			collision.rotate(line.get_points()[i].angle())
			collision.shape = rectangle_collision
			static_body.position = line.get_point_position(i)
			#rectangle_collision.collide_and_get_contacts(Transform2D(line.get_points()[i].x,line.get_points()[i].y,line.get_points()[i]),rectangle_collision,Transform2D(rectangle_collision.extents.x,rectangle_collision.extents.y,rectangle_collision.extents))
			static_body.add_child(collision)
		
		
		
		
		
		
	#well this function, it gets the position vector of the copies in the list of copies array
	#then appends it to the copies normal array
func copies_normal_vector():
	for i in range(0,list_of_copies.size()):
		if is_sprite_created==true:
			var pos = line.get_points()
			copies_normal_array.append(pos[i])
		
		
		
		
		

"""this is to shift the copies position normal to the next neighbor of point in the line method
it needs the traverse vector array list to function
its not perfect yet but can be improved, feel free to uncomment the code and explore it """
#func traverse_each_copy(pick_index , shift_vector):
#	list_of_copies[pick_index].linear_velocity = traverse_vector_array[pick_index] -shift_vector[pick_index]
#	pass
	
	
	
	
	
	#this allows you to edit the position of the point of the line method
	#while the program is running, although a save state feature can be added
	#so that the object will remember the position that is was changed to when
	#the program runs again
	#it accepts the line point index to be adjusted
func line_vector_edit(point_edit_index):
	if Input.is_action_pressed("ui_page_up"):
		line.set_point_position(point_edit_index,get_viewport().get_mouse_position())
	pass





# L shape arrangement technique is a new way to arrange copies of object
# without making use of line arrangement, think of points on a letter L then
# arrange your object on the points of the letter L

#note this feature is still under construction, its still at its infancy,
#your contribution can help improve this feature also object will be arrangement directly
#from the program while running not just restricted to an L shape 
func L_shape_arrangement(is_using_L_arrangement,change_in_time):
	time += change_in_time
	#add to the value of f every one seconds
	if time > 1:
		time =0
		f+=1
		
		#if f as reached the end of the list, let it stay at the end of the list
		#rather than recounting
	if f >list_of_copies.size()-1:
		f =list_of_copies.size()-1
		
	if is_using_L_arrangement == true:
		for i in range(0, list_of_copies.size()):
			 
			#this variable should be passed from the inspector
			var arranger = Vector2(150,50)
			
			#this is the initial position of the first element in the list of copies
			list_of_copies[0].position = arranger
			
			#this sets the next item in the list of copies to the position before it and then adds vector(50,0)
			#note(vector2(0,100)) should be passed from the inspector to this function
			list_of_copies[f].position = list_of_copies[f-1].position + Vector2(0,100)
			
			#print("this is F: ",f)
			#list_of_copies[i].position +=list_of_copies[i-1].position *get_process_delta_time()
			#arranger+= Vector2(0,list_of_copies[i].position.y)
		
		

#this involves removing previous data and  substituting existing data to the old position
#although its not perfect because you may not be able to fully substitute exist data
#because change_type function will return a newly created copy
#but you get the gist, taking old data(including all previous properties) from somewhere
#and putting it in a new position

#this function takes, old copy of object, the old position in list of copies, then the object index
#check the ready function on how this function is called for more understanding
func coexistence_by_data(old_object, old_pos_in_list, object_number):
	#for i in range(0,list_of_copies.size()):
	
	#data coexistence selector(int) is a selector that chooses the "currently" coexisting data
	#if selector value is 0, this means i am selecting the value in the zeroth position of old_pos_in_list array
	#and value in the zeroth position of object_number array
	
	#selector higher than 1, may affect object number array
	if list_of_copies.has(old_object):
		var pos = line.get_points()
		#RUN THIS PROCESS ONCE ,BECAUSE IT WILL BE CALLED IN THE PROCESS FUNCTION
		for m in range(1):
			list_of_copies.remove(old_pos_in_list[data_coexistence_selector])
			var return_value = change_type(old_object,object_number[data_coexistence_selector])
			list_of_copies.insert(old_pos_in_list[data_coexistence_selector],return_value)
			
		#ALWAYS UPDATE THE LIST OF COPIES THAT WAS CHANGED,POSITION BUT THIS DOESNT WORK WELL
		list_of_copies[old_pos_in_list[data_coexistence_selector]].position = pos[old_pos_in_list[data_coexistence_selector]]
		data_coexistence_happened = true
		
		
	
	pass



#this function is very useful in mixing copies of different type on the same line
#arrangement technique, for example having a static body(at point 0) and
#having a rigidbody(at point 1) 

#this accepts the index of the point where the copies is on the line arrangement
#boolean toggles the activation of this function
func coexistence(number_to_coexist,boolean):
	if boolean==true:
		#note, this is not working accurately as it should,its difficult to explain at this point
		#but what it suppose to achieve is a multiple coexistence of different points on the line
		#arrangement by accepting a poolintarray and each point can be manipulated
		
		for i in range(0,point_to_coexist.size()):
			if number_to_coexist[i] >=0:#if you dont want to coexist any point, set poolintarray to -1
				var pos = line.get_points()
				#check the top of this progeam for "object_num_array"
				var returned_object = change_type(list_of_copies[number_to_coexist[i]],object_array_num)
				
				#print("returned object: ", returned_object)
			#	list_of_copies[number_to_coexist].queue_free()
				
				#remove the previous copy in that position
				list_of_copies.remove(number_to_coexist[i])
				
				#i am not sure if erasing the previous copy in that position is a great idea
				list_of_copies.erase(number_to_coexist[i])
				
				
				
				#then insert the returned object from change_type function to that previous position
				list_of_copies.insert(number_to_coexist[i],returned_object)
				
				#set the new copy to the previous position
				list_of_copies[number_to_coexist[i]].position = pos[i]
				
				
				#print("the added: ", list_of_copies[number_to_coexist[i]])
		
	#else if boolean is false, then no coexistence occur
	else:
		return
	
	#returned_object.position = pos[number_to_coexist]
	#list_of_copies.append(returned_object)
	#if list_of_copies.has(number_to_coexist)==true:
	#print(number_to_coexist)
	#change_type(list_of_copies[number_to_coexist],object_array_num, number_to_coexist)
	#list_of_copies.remove(number_to_coexist)
	#print("hellow")
#	list_of_coexistence.append(list_of_copies)
#	if list_of_coexistence.size() > 10:
#		list_of_coexistence.clear()
	#print("list_of_coexistence: " , list_of_coexistence)
	
	pass
	
	
	
#this function changes the type of an existing object in the list of copies,
# this works with coexistence function
#it accepts the previous object and the index of the previous object
func change_type(previous_object,index_copy):

#create  a different type if previous_object is StaticBody2D
#then add sprite and collision shape as a child
	if previous_object is StaticBody2D:
		var box_shape = RectangleShape2D.new()
		var r_copy = RigidBody2D.new()
		var s_copy = Sprite.new()

		var load_path_images = load(sprites[index_copy].get_load_path()).resource_path
		s_copy.texture = load(load_path_images)

		var c_copy = CollisionShape2D.new()
		box_shape.extents = s_copy.get_rect().size
		c_copy.shape = box_shape
		
		image_copies_container.add_child(r_copy)
		r_copy.add_child(s_copy)
		r_copy.add_child(c_copy)
		
		#r_copy.hide()
		randomize()
		is_rigid_body_properties_showing =true
		
		return r_copy
	
	#create  a different type if previous_object is rigidbody2D
	#you could program it to create a "user input type" rather than the
	#hard_coded type
	if previous_object is RigidBody2D:
		var box_shape = RectangleShape2D.new()
		var static_copy = StaticBody2D.new()
		var s_copy = Sprite.new()

		var load_path_images = load(sprites[index_copy].get_load_path()).resource_path
		s_copy.texture = load(load_path_images)
		var c_copy = CollisionShape2D.new()
		box_shape.extents = s_copy.get_rect().size
		c_copy.shape = box_shape
		
		image_copies_container.add_child(static_copy)
		static_copy.add_child(s_copy)
		static_copy.add_child(c_copy)
		#static_copy.hide()
		return static_copy
		
		pass