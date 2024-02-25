/*
This struct contains functions that tests objects for similar specs.
All test will return either true or false to indicate wether the original object and potential copy is identical in the tests regard
*/




(--START script
	
	
	--Get Repository struct from action.ms:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "repository.ms" --Combines directory and filename to create a path
	file_repository = fileIn path_script
	my_file_repository = file_repository
	


	struct Tests
	(
		
		----------------------------------------------------------------------------------------------------------------------------
		fn Same_Name original_obj potential_copy =
		(
			return_value = (trimLeft (trimRight (toLower (original_obj.name)))) == (trimLeft (trimRight (toLower (potential_copy.name))))
			
			return return_value
		),
		
		----------------------------------------------------------------------------------------------------------------------------
		fn Same_Mesh_Class original_obj potential_copy =
		(
			return_value = (classOf original_obj.baseObject) == (classOf potential_copy.baseObject)
			
			return return_value
		),
		
		----------------------------------------------------------------------------------------------------------------------------
		fn Same_MaterialName original_obj potential_copy =
		(
			return_value
			
			if original_obj.material != undefined and potential_copy.material != undefined then
			(
				return_value = original_obj.material.name == potential_copy.material.name
			)
			else return_value = false
			
			return return_value
		),
		
		----------------------------------------------------------------------------------------------------------------------------
		fn Same_Pos original_obj potential_copy spn_tolerance =
		(
			return_value = true
			
			for i in 1 to 3 where return_value == true do
			(
				if original_obj.pos[i] + spn_tolerance < potential_copy.pos[i] do return_value = false
				if original_obj.pos[i] - spn_tolerance > potential_copy.pos[i] do return_value = false
			)
			
			return return_value
		),
		
		----------------------------------------------------------------------------------------------------------------------------
		fn Same_Modifier original_obj potential_copy =
		(
			return_value = false
			
			for org_modifier in original_obj.modifiers do for copy_modifier in potential_copy.modifiers where org_modifier == copy_modifier do return_value = true
				
			return return_value
		),
		
		----------------------------------------------------------------------------------------------------------------------------
		fn Same_Size original_obj potential_copy spn_tolerance =
		(
			return_value = true
			
			original_obj_size = original_obj.max - original_obj.min
			potential_copy_size = potential_copy.max - potential_copy.min
			
			for i in 1 to 3 where return_value == true do
			(
				if potential_copy_size[i] + spn_tolerance < original_obj_size[i] do return_value = false
				if potential_copy_size[i] - spn_tolerance > original_obj_size[i] do return_value = false
			)
			
			
			return return_value
		),
		
		----------------------------------------------------------------------------------------------------------------------------
		fn Same_verticesCount original_obj potential_copy =
		(
			original_obj_base_mesh = original_obj.baseObject.mesh
			potential_copy_base_mesh = potential_copy.baseObject.mesh
			
			return_value = (getNumVerts original_obj_base_mesh) == (getNumVerts potential_copy_base_mesh)
			
			return return_value
		),
		
		----------------------------------------------------------------------------------------------------------------------------
		fn Same_faceCount original_obj potential_copy =
		(
			original_obj_base_mesh = original_obj.baseObject.mesh
			potential_copy_base_mesh = potential_copy.baseObject.mesh
			
			return_value = (getNumFaces original_obj_base_mesh) == (getNumFaces potential_copy_base_mesh)
			
			return return_value
		),
		
		----------------------------------------------------------------------------------------------------------------------------
		fn Same_VerticesPositions original_obj potential_copy spn_tolerance =
		(
			return_value = true
			
			return_value = (Same_verticesCount original_obj potential_copy) -- Vertices count check
			
			if return_value == true do
			(
				original_obj_base_mesh = original_obj.baseObject.mesh
				potential_copy_base_mesh = potential_copy.baseObject.mesh
				original_obj_vertices_count = getNumVerts original_obj_base_mesh
				
				
				for vertNum in 1 to original_obj_vertices_count where return_value do
				(
					original_obj_vert_pos = getVert original_obj_base_mesh vertNum
					potential_copy_vert_pos = getVert potential_copy_base_mesh vertNum
					
					for axis in 1 to 3 where return_value == true do
					(
						if original_obj_vert_pos[axis] + spn_tolerance < potential_copy_vert_pos[axis] do return_value = false
						if original_obj_vert_pos[axis] - spn_tolerance > potential_copy_vert_pos[axis] do return_value = false
					)
				)
				
			)
			
			return return_value
		),

		----------------------------------------------------------------------------------------------------------------------------
		fn Same_SmoothingGroups original_obj potential_copy =
		(
			return_value = true
			
			return_value = (Same_faceCount original_obj potential_copy) -- Face count check
			
			if return_value == true do
			(
				original_obj_base_mesh = original_obj.baseObject.mesh
				potential_copy_base_mesh = potential_copy.baseObject.mesh
				
				original_obj_face_count = getNumFaces original_obj_base_mesh
				
				
				for face in 1 to original_obj_face_count where return_value == true do
				(
					original_obj_face_sg = (my_file_repository.getFaceSmoothGroupB original_obj_base_mesh face)
					potential_copy_face_sg = (my_file_repository.getFaceSmoothGroupB potential_copy_base_mesh face)
					--Gets an array of smoothing groups for this face
					
					for i in 1 to original_obj_face_sg.count where return_value == true do
					(
						if original_obj_face_sg[i] != potential_copy_face_sg[i] do return_value = false
					) --Loops through each array item and compare them
					
				)
				
			)
			
			return return_value
		),
		
		----------------------------------------------------------------------------------------------------------------------------
		fn Same_FaceNormals original_obj potential_copy =
		(
			return_value = true
			
			return_value = (Same_faceCount original_obj potential_copy) -- Face count check
			
			if return_value == true do
			(
				original_obj_base_mesh = original_obj.baseObject.mesh
				potential_copy_base_mesh = potential_copy.baseObject.mesh
				original_obj_face_count = getNumFaces original_obj_base_mesh
				
				
				for face in 1 to original_obj_face_count where return_value == true do
				(
					if (getFaceNormal original_obj_base_mesh face) != (getFaceNormal potential_copy_base_mesh face) do return_value = false
				)
				
			)
			
			return return_value
		)
		
		----------------------------------------------------------------------------------------------------------------------------
	)--END struct Tests
	
	
	
	
	
)--END script


















