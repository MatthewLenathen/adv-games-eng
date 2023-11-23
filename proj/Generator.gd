tool # Adding this keyword lets the changes made here, affect the editor
extends Spatial

# Variables
var mesh_node : MeshInstance = null
var noise : OpenSimplexNoise = null
var vertices : PoolVector3Array
var UVs : PoolVector2Array
var normals : PoolVector3Array
var indices : PoolIntArray
var initialised = false
var cloud : PackedScene = load("res://Basic Billboard clouds.tscn")
var particle_list : Array

# All of the following are the variables that can change the mesh, so we need them to be settable and gettable.
# The export keyword means that they will be saved along with the scene, and editable in the tool 
# For most of these a default value is set to get a decent looking default terrain

# nodePath points to the meshInstance
export (NodePath) var nodePath = null setget setNodePath
func setNodePath(newPath):
	resetMesh()
	nodePath = newPath
	initialiseMesh()

# viewDistance is how big the mesh will be
export (int) var viewDistance = 256 setget setViewDistance
func setViewDistance(newVd):
	resetMesh()
	viewDistance = newVd
	#view_distance = clamp(view_distance, 1, 256) # optional line to limit the view distance
	initialiseMesh()

# variable for height of mesh
export (int) var height = 48 setget setHeight
func setHeight(newHeight):
	resetMesh()
	height = newHeight
	initialiseMesh()

# heightBias acts as an intensity control on the noise, will be explained in the vertex generation function
export (float) var heightBias = 1.65 setget setHeightBias
func setHeightBias(newBias):
	resetMesh()
	heightBias = newBias
	initialiseMesh()


# Now, the noise variables, info from: https://docs.godotengine.org/en/3.5/classes/class_opensimplexnoise.html
# Seed is just the seed to generate the random values
export (int) var noiseSeed = 30 setget setSeed
func setSeed(newSeed):
	resetMesh()
	noiseSeed = newSeed
	initialiseMesh()

# Octaves is the number of noise layers that contribute to the end result
export (int) var octaves = 4 setget setOctaves
func setOctaves(newOctaves):
	resetMesh()
	octaves = newOctaves
	initialiseMesh()

# Period of the base octave, lower period results in higher frequency noise
export (float) var period = 100.0 setget setPeriod
func setPeriod(newPeriod):
	resetMesh()
	period = newPeriod
	initialiseMesh()

# Lacunarity is the difference in period between octaves
export (float) var lacunarity = 3.0 setget setLacunarity
func setLacunarity(newLacunarity):
	resetMesh()
	lacunarity = newLacunarity
	initialiseMesh()

# Persistance is the contribution factor of different octaves, e.g. persistance of 1 = all octaves same contribution
export (float) var persistence = 0.25 setget setPersistance
func setPersistance(newPersistance):
	resetMesh()
	persistence = newPersistance
	initialiseMesh()
	
	
# Cloud export vars
export (int) var numberOfClouds = 10 setget setCloudNum
func setCloudNum(newNumberOfClouds):
	resetClouds()
	numberOfClouds = newNumberOfClouds
	generateClouds()

# This function generates the vertices based on the view distance and noise generator
func genVertices():
	vertices = PoolVector3Array()
	# centre offset will center the terrain to the scene
	var centreOffset = viewDistance / 2
	# +1 to get the final row/column, as "in range" doesnt include the number given
	for x in range(viewDistance+1):
		for y in range(viewDistance+1):
			# height bias is applied directly to the noise value, before it gets multiplied by height
			# This makes valleys deeper and heights steeper, more extreme values, can be tuned
			var h = noise.get_noise_2d(x, y) * heightBias
			
			h = h * h * sign(h) # this line squares h, but correctly keeps the sign
			# e.g. h = -30 * -30 * sign(-30) 
			# h = -30 * -30 * -1
			# h = -900
			h *= height

			# append vertices to array
			vertices.append(Vector3(x-centreOffset,h,y-centreOffset))

# This function generates texture coordinates 
func genUVs():
	UVs = PoolVector2Array()
	var offset = 1.0 / (viewDistance) # gives the size of the step in uv space (0-1)
	for x in range(viewDistance+1):
		for y in range(viewDistance+1):
			UVs.append(Vector2(offset*x, offset*y)) # means the texture will be stretched accross the entire terrain

# Will generate indices in triangle strip format
func genIndices():
	indices = PoolIntArray()
	for index in range((viewDistance+1)*viewDistance):
		indices.append(index)
		indices.append(index+(viewDistance+1))
		# if statement used to stitch the end of one row onto the next
		if index != 0 and (index+1) % (viewDistance+1) == 0:
			indices.append(index+(viewDistance+1))
			indices.append(index+1)

# Will generate normals for the terrain
func genNormals():
	# First, create the normal array and fill it with 0 vectors
	normals = PoolVector3Array()
	normals.resize(vertices.size())
	for f in range(normals.size()):
		normals[f] = Vector3(0,0,0)

	# Next, loop in steps of two to consider each triangle defined by 3 indices
	for i in range(0, indices.size()-2, 2):
		var ia = indices[i]
		var ib = indices[i+1]
		var ic = indices[i+2]

		# check for degenerate triangles, just go next if so
		if ia==ib or ib==ic or ia==ic:
			continue

		# compute normals
		var a :Vector3 = vertices[ia]
		var	b :Vector3 = vertices[ib]
		var	c :Vector3 = vertices[ic]

		var edge1 = c-a
		var edge2 = b-a
		var normal = edge1.cross(edge2)

		normals[ia] +=  normal
		normals[ib] +=  normal
		normals[ic] +=  normal

	# finally, normalise all normals
	for i in range(normals.size()):
		normals[i] = normals[i].normalized()

# This will use all the helper functions to generate the mesh
# help from https://docs.godotengine.org/en/3.5/classes/class_arraymesh.html
func genMesh():
	# all previous functions
	genVertices()
	genUVs()
	genIndices()
	genNormals()
	
	var mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(ArrayMesh.ARRAY_MAX)
	arrays[ArrayMesh.ARRAY_VERTEX] = vertices
	arrays[ArrayMesh.ARRAY_TEX_UV] = UVs
	arrays[ArrayMesh.ARRAY_INDEX] = indices
	arrays[ArrayMesh.ARRAY_NORMAL] = normals
	
	# Create the mesh from the arrays
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	
	return mesh

# Generate noise with all the variables
func generateNoise():
	noise = OpenSimplexNoise.new()
	noise.seed = noiseSeed
	noise.octaves = octaves
	noise.period = period
	noise.lacunarity = lacunarity
	noise.persistence = persistence

# This function will generate the noise and also the mesh
func initialiseMesh():
	# If the mesh is already initialised just return
	if initialised:
		return

	if nodePath == null:
		return

	mesh_node = get_node(nodePath)
	if mesh_node == null:
		return

	generateNoise()
	mesh_node.mesh = genMesh()
	initialised = true

# cloud stuff? gets called when changing number of clouds in editor
func generateClouds():
	var rng = RandomNumberGenerator.new()
	for i in range(numberOfClouds):
		
		var cloudInstance = cloud.instance()
		var x : float = rng.randf_range(-viewDistance/2.0,viewDistance/2.0)
		var y : float = rng.randf_range(60,70)
		var z : float = rng.randf_range(-viewDistance/2.0,viewDistance/2.0)
		
		cloudInstance.translation = Vector3(x,y,z)
		cloudInstance.rotation = Vector3(0,x,0)
		
		cloudInstance.add_to_group("clouds")
		add_child(cloudInstance)

# function allows the clouds to be deleted, as the instances are created in a loop, add them to group
func resetClouds():
	for N in self.get_children():
		if(N.is_in_group("clouds")):
			N.queue_free()
		
# This function will clean the mesh node to be rebuilt with new values
func resetMesh():
	if mesh_node != null and initialised:
		initialised = false
		mesh_node.mesh = null

# Called when entering the scene
func _ready():
	initialiseMesh()
