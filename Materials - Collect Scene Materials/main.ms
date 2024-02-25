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
	
	--Get Arr_From_File struct from "arr_from_file.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "arr_from_file.ms" --Combines directory and filename to create a path
	file_arr = fileIn path_script
	
	--Get scene_collect struct from "collect_scene.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "collect_scene.ms" --Combines directory and filename to create a path
	file_collect_scene = fileIn path_script
	
	--Get Scene_Reassign struct from "reassign_scene.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "reassign_scene.ms" --Combines directory and filename to create a path
	file_reassign_scene = fileIn path_script
	
	--Get Scene_Apply struct from "apply_scene.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "apply_scene.ms" --Combines directory and filename to create a path
	file_apply_scene = fileIn path_script
	

	
	struct Main
	(
		fn run =
		(
			setWaitCursor()
			matEditOpen = MatEditor.isOpen() --Stores True or False depending on wether matEditor is open
			MatEditor.Close() 
			with redraw off
			(
				--dict_from_file delimiter:
				settings_delim = "="
				
				--mergeLUT delimiter:
				mergeLUT_delim = ","
				
				--settings_dict contains interface settings:
				--Initialize the "Dict_From_File" struct and use the the make_dict function. It reads the text file and returns a dictionary:
				settings_dict = (file_dict.make_dict "settings.ini" settings_delim del_file:True)
				
				--mergeLUT_arr contains non-materials look-up table:
				--Initialize the "Arr_From_File" struct and use the the make_arr function. It reads the text file and returns a dictionary:
				mergeLUT_arr = (file_arr.make_arr "mergeLUT.txt" mergeLUT_delim del_file:True)
				
				--Dictionary values are stored as normal variables:
				includeSelected =      settings_dict[(toLower "inclSelected")]
				includeNotSelected = settings_dict[(toLower "inclNotSelected")]
				includeVisible =         settings_dict[(toLower "inclVisible")]
				includeHidden =         settings_dict[(toLower "inclHidden")]
				includeNotFrozen =    settings_dict[(toLower "inclNonFrozen")]
				includeFrozen =         settings_dict[(toLower "inclFrozen")]
				
				_undo =                   settings_dict[(toLower "undo")]
				firstSlot =                settings_dict[(toLower "firstSlot")]
				lastSlot =                 settings_dict[(toLower "lastSlot")]
				maxNumSubSlots =    settings_dict[(toLower "maxNumSubSlots")]
				
				dir_proj =                 settings_dict[(toLower "dir_proj")]
				name_proj =             settings_dict[(toLower "name_proj")]
				path_proj =               settings_dict[(toLower "path_proj")]
				saveScene =             settings_dict[(toLower "save")]
				closeScene =            settings_dict[(toLower "close")]
				path_log =                settings_dict[(toLower "path_logFile")]
				newName_proj =        settings_dict[(toLower "newName_proj")]
				newPath_proj =         settings_dict[(toLower "newPath_proj")]
				
				--Initialize the selection struct:
				my_selection = file_selection \
				includeSelected includeNotSelected includeVisible includeHidden \
				includeNotFrozen includeFrozen
				
				--Save selection as allObjects:
				allObjects = my_selection.nonInstancesArray
				
				--Update meshes before script:
				for obj in allObjects do (update obj)
				
				--Set correct undo setting and run the functions
				if _undo == 2 do holdMaxFile()
				if _undo == 1 or _undo == 2 do clearUndoBuffer()
				undo "Collect_Materials" (_undo == 3)
				(
					--Deselect objects:
					local preSelObjs = (for i in selection collect i)
					clearSelection()
					
					-----------------------------------------------------------------------------------------------------
					--Collect scene:
					
					--Make a class instance of struct scene_collect in file_collect_scene:
					scene_collect = file_collect_scene()
					
					--Fill arrays in struct instance scene_collect:
					scene_collect.populate_arrays allObjects mergeLUT_arr
					
					--Fill arrays with collected info:
					org_obj_arr = scene_collect.org_obj_arr
					org_matNames_arr = scene_collect.org_matNames_arr
					org_matIDs_arr = scene_collect.org_matIDs_arr
					org_materials_arr = scene_collect.org_materials_arr
					
					------------------------------------------------------------------------------------------------------
					--Reassign scene:
					
					--Make class instance of struct Scene_Reassign in file_reassign_scene:
					scene_reassign = file_reassign_scene()
					
					--Run function that reassigns collected information:
					scene_reassign.fn_run org_obj_arr org_matNames_arr org_materials_arr maxNumSubSlots firstSlot lastSlot
					
					--Fill arrays with reassign information:
					new_obj_arr = scene_reassign.new_obj_arr
					new_matNames_arr = scene_reassign.new_matNames_arr
					new_materials_arr = scene_reassign.new_materials_arr
					
					
					------------------------------------------------------------------------------------------------------
					--Apply scene changes:
					
					--Make class instance of struct Scene_Apply in file_apply_scene:
					apply_scene = file_apply_scene()
					
					--Run function that applies scene changes:
					apply_scene.faceID_op org_obj_arr org_matIDs_arr org_matNames_arr new_obj_arr new_matNames_arr new_materials_arr allObjects
					
					
					------------------------------------------------------------------------------------------------------
					--TESTING:
					
					--org:
					--print "ORG ARRAYS:"
					--print "org_obj_arr: "
					--print org_obj_arr
					--print "org_matNames_arr: "
					--print org_matNames_arr
					--print "org_matIDs_arr: "
					--print org_matIDs_arr
					--print "org_materials_arr: "
					--print org_materials_arr
					
					--new:
					--print "NEW ARRAYS"
					--print "new_obj_arr: "
					--print new_obj_arr
					--print "new_matNames_arr: "
					--print new_matNames_arr
					--print "new_materials_arr: "
					--print new_materials_arr
					
					------------------------------------------------------------------------------------------------------
					
				)--END undo scope
				
				--Update meshes after script:
				for obj in allObjects do (update obj)
				
				--If requested, save and close scene:
				if saveScene == True do saveMaxFile(newPath_proj)
				if closeScene == True do quitMax #noPrompt
				
			)--END with redraw off
			
			--Put scene back to user state:
			completeRedraw()
			select preSelObjs
			if matEditOpen do MatEditor.Open() 
			setArrowCursor()	
			
			--Messagebox "Done":
			messagebox "Done"
			
		)--END run function
		
		
	)--END Struct Main
		
		
)--END script
