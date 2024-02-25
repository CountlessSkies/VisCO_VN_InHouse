(--START script
	
	--Get Selection struct from "selection.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "selection.ms" --Combines directory and filename to create a path
	file_selection = fileIn path_script
	
	--Get Dict_From_File struct from "dict_from_file.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "dict_from_file.ms" --Combines directory and filename to create a path
	file_dict = fileIn path_script

	
	struct Main
	(
	
		--START function to set mesh edges visible: (Mapped functions takes an array as the first argument. It then treats the variable that contains the array as a single object, looping through all objects in the array)
		mapped fn edgesVisible object_arr threshold =
		(
			if classOf object_arr.baseobject == Editable_mesh and (getNumFaces object_arr.baseobject.mesh) > 0 do
			(
				edgeList = #{1..(object_arr.baseobject.mesh.numFaces * 3)}
				meshop.autoEdge object_arr.baseobject.mesh edgeList threshold type:#SetClear
				update(object_arr)
			)
		),--END function to set mesh edges visible
		
		
		
		
		
		
		--START function to convert objects:
		mapped fn convertOp object_arr mesh_op mod_op =
		(
			--Variables:
			mod_storage = #()
			
			--Get all instances of the object and store it in Instances:
			InstanceMgr.GetInstances object_arr &Instances
			
			--mod_op delete modifiers:
			if mod_op == 1 do for i in object_arr.modifiers.count to 1 by -1 do deleteModifier object_arr i
			
			--mod_op bake modifiers:
			if mod_op == 2 do pass
			
			--mod_op maintain modifiers:
			if mod_op == 3 do
			(
				--store modifiers in array:
				for i in object_arr.modifiers do append mod_storage i
				--delete modifiers:
				for i in object_arr.modifiers.count to 1 by -1 do deleteModifier object_arr i
			)
			
			--Convert object:
			if mesh_op == 1 do convertToPoly object_arr
			if mesh_op == 2 do convertToMesh object_arr
				
			--Convert instances of the object:
			for obj in Instances where obj != object_arr do 
			(
				for i in obj.modifiers.count to 1 by -1 do deleteModifier obj i
				obj.baseobject = object_arr.baseobject
			)
			
			--Put modifiers back on: (The array might be empty, depending on the mod_op choosen)
			for the_mod in mod_storage do addModifier object_arr the_mod before:object_arr.modifiers.count
			
		),--END function to convert objects (convertOp)

		
		
		
			fn run =
			(
				setWaitCursor()
				with redraw off
				(
					--Initialize the "Dict_From_File" struct and use the the read_file function. It reads the text file and returns a dictionary:
					the_dict = (file_dict.make_dict "settings.ini" "=" del_file:True)
					
					--Dictionary values are stored as normal variables:
					includeSelected =      the_dict[(toLower "inclSelected")]
					includeNotSelected = the_dict[(toLower "inclNotSelected")]
					includeVisible =         the_dict[(toLower "inclVisible")]
					includeHidden =         the_dict[(toLower "inclHidden")]
					includeNotFrozen =    the_dict[(toLower "inclNonFrozen")]
					includeFrozen =         the_dict[(toLower "inclFrozen")]
					includeMesh =           the_dict[(toLower "inclMesh")]
					includePoly =            the_dict[(toLower "inclPoly")]
					includeSpline =          the_dict[(toLower "inclSpline")]
					includeOther =          the_dict[(toLower "inclOther")]
					_mesh_op =             the_dict[(toLower "conv_type")]
					AutoEdge =              the_dict[(toLower "edgesVisible")]
					_mod_op =               the_dict[(toLower "mod_action")]
					workInstances =        the_dict[(toLower "doInstances")]
					_undo =                   the_dict[(toLower "undo")]
					dir_proj =                 the_dict[(toLower "dir_proj")]
					name_proj =             the_dict[(toLower "name_proj")]
					path_proj =               the_dict[(toLower "path_proj")]
					saveScene =             the_dict[(toLower "save")]
					closeScene =            the_dict[(toLower "close")]
					path_log =                the_dict[(toLower "path_logFile")]
					newName_proj =        the_dict[(toLower "newName_proj")]
					newPath_proj =         the_dict[(toLower "newPath_proj")]
					
					--Initialize the selection struct:
					my_selection = file_selection \
					includeSelected includeNotSelected includeVisible includeHidden \
					includeNotFrozen includeFrozen includeMesh \
					includePoly includeSpline includeOther
					
					--Set correct undo setting and run the functions
					if _undo == 2 do holdMaxFile()
					if _undo == 1 or _undo == 2 do clearUndoBuffer()
					undo "ConvertToPoly" (_undo == 3)
					(
						--Deselect objects:
						local preSelObjs = (for i in selection collect i)
						clearSelection()
						
						--Set correct selection array, depending on wether instanced objects are to be included or not:
						obj_array = (if workInstances then my_selection.nonInstancesArray else my_selection.singleObjectsArray)
						
						--Set all mesh object edges visible: (object array, autoEdge threshold)
						if AutoEdge do Main.edgesVisible obj_array 0
						
						--Convert objects: (object array, operation type)
						Main.convertOp obj_array _mesh_op _mod_op
						
						--Select previously selected objects:
						select preSelObjs
						
					)--END undo scope
					
					--If requested, save and close scene:
					if saveScene == True do saveMaxFile(newPath_proj)
					if closeScene == True do quitMax #noPrompt
					
				)--END with redraw off
				completeRedraw()
				setArrowCursor()	
			)--END run function
		
		
	)--END Struct Main
		
		
)--END script
