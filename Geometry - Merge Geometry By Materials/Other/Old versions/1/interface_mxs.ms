(--START Interface
	
	
	------------------------------------------------------------------------------------------------------------------------------------------
	--Get Error_Check struct from error_check.ms:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "error_check.ms" --Combines directory and filename to create a path
	file_error_check = fileIn path_script
	
	--Get Selection struct from "selection.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "selection.ms" --Combines directory and filename to create a path
	file_selection = fileIn path_script
	
	--Get Collect_Materials struct from "collect_materialsn.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "collect_materials.ms" --Combines directory and filename to create a path
	file_collect_materials = fileIn path_script
	
	--Get Clean_Materials struct from "clean_materials.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "clean_materials.ms" --Combines directory and filename to create a path
	file_clean_materials = fileIn path_script
	
	--Get Prepare_Objects struct from "prepare_objects.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "prepare_objects.ms" --Combines directory and filename to create a path
	file_prepare_objects = fileIn path_script
	
	--Get Separate_FaceIDs struct from "separate_faceIDs.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "separate_faceIDs.ms" --Combines directory and filename to create a path
	file_separate_faceIDs = fileIn path_script
	
	--Get Merge_Geometry struct from "merge_geometry.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "merge_geometry.ms" --Combines directory and filename to create a path
	file_merge_geometry = fileIn path_script
	
	------------------------------------------------------------------------------------------------------------------------------------------
	rollout rollout_main "Break Or Merge By Materials"
	(
		group "Object Selection"
			(
				checkBox chkBox_inclSelected "Include selected objects" checked:true
				checkBox chkBox_inclNotSelected "Include non-selected objects" offset:[175,-20] checked:false
				checkBox chkBox_inclVisible "Include visible objects" checked:true
				checkBox chkBox_inclHidden "Include hidden objects" offset:[175,-20] checked:true
				checkBox chkBox_inclNotFrozen "Include non-frozen objects" checked:true
				checkBox chkBox_inclFrozen "Include frozen objects" offset:[175,-20] checked: True
				label lbl_1 ""
			)
			
		group "Settings: "
			(
				checkBox chkBox_breakMultiMats "Break up objects with multimaterials" checked: True \
					tooltip: "Will break up \separate an object into several objects according to submaterials"
				checkBox chkBox_mergeByMat "Merge by materials" checked: True \
					tooltip: "Merges objects with the same material"
			)
			
			
		group "Runtime Settings"
			(
				radioButtons rBtn_undo "Undo Level:" labels:#("None", "Hold") align:#left default: 2
				radiobuttons rBtn_saveExit "After Completion:" labels:#("Nothing", "Save", "Save and Exit") align:#left columns:3 offsets:#([0,0], [0,0], [-20,0]) offset:[180,-35]
				editText txt_savePath "Save Path:" fieldWidth:360 enabled:False
				button btn_browse "Browse" align:#left offset:[425,-25] enabled: False
				label lbl_3 ""
				
			)
		
				label lbl_4 ""
				button btn_execute "Execute" Align: #left
				label lbl_5 ""
			
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		on rBtn_saveExit changed state do
		(
			if state == 1 do
			(
				txt_savePath.enabled = False
				btn_browse.enabled = False
			)
			if state == 2 or state == 3 do
			(
				txt_savePath.enabled = True
				btn_browse.enabled = True
			)
		)

		on btn_browse pressed do 
		(
			filePath = getSaveFileName()
			if filePath == undefined then filePath = txt_savePath.text
			txt_savePath.text=filePath
		)
			
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		on btn_execute pressed do
		(
			-----------------------------------------------------------------------------------------------------------------------------------------------------
			--SELECTION:
			
			--Save user selection in variables
			includeSelected = chkBox_inclSelected.checked
			includeNotSelected  = chkBox_inclNotSelected.checked
			includeVisible = chkBox_inclVisible.checked
			includeHidden  = chkBox_inclHidden.checked
			includeNotFrozen = chkBox_inclNotFrozen.checked
			includeFrozen = chkBox_inclFrozen.checked
			
			--Initialize the selection struct:
			my_selection = file_selection \
			includeSelected includeNotSelected includeVisible includeHidden \
			includeNotFrozen includeFrozen
			
			--Save selection sets:
			all_objects = my_selection.allObjects
			nonInstances = my_selection.nonInstancesArray
			duplicateObjects = my_selection.duplicateObjectsArray
			singleObjects = my_selection.singleObjectsArray
			
			-----------------------------------------------------------------------------------------------------------------------------------------------------
			--UPDATE MESHES FUNCTION:
			fn Update_Meshes collections =
			(
				for current_collection in collections do for obj in current_collection do (update obj)
			)
			
			-----------------------------------------------------------------------------------------------------------------------------------------------------
			--PREPARE SCENE:
			
			setWaitCursor()
			
			--Set correct undo setting and run the functions
			if rBtn_undo.state == 2 do holdMaxFile()
			clearUndoBuffer()
			
			--Deselect objects:
			local preSelObjs = (for i in selection collect i)
			clearSelection()
			
			with redraw off
			(
				-----------------------------------------------------------------------------------------------------------------------------------------------------
				--ERROR CHECKING:
				
				--Make an instance of the error checking struct:
				my_file_error_check = file_error_check all_objects rBtn_saveExit.state txt_savePath.text
				
				local continue_operation = true--Stops the script from running if set to false
				
				--Check if save file path is valid:
				if continue_operation do if ( my_file_error_check.SavePath_Valid() ) != true do continue_operation = false
				
				
				-----------------------------------------------------------------------------------------------------------------------------------------------------
				--MAIN OPERATION:
				
				if continue_operation and (chkBox_breakMultiMats.checked or chkBox_mergeByMat.checked) do
				(
					
					--Update meshes:
					Update_Meshes #(all_objects, nonInstances, duplicateObjects, singleObjects)
					
					--COLLECT MATERIALS:
					
					--Initialize material collection from all_objects:
					my_file_collect_materials = file_collect_materials all_objects
					
					--Collect materials:
					my_file_collect_materials.Collect_Materials()
					
					-----------------------------------------------------------------------------------------------------------------------------------------------------
					--CLEAN UP MATERIALS
					
					--Initialize clean_materials struct:
					my_file_clean_materials = file_clean_materials all_objects my_file_collect_materials.allMaterials my_file_collect_materials.allMaterials_names
					
					--Update meshes:
					Update_Meshes #(all_objects, nonInstances, duplicateObjects, singleObjects)
					
					--Run the function to clean up objects 
					my_file_clean_materials.Single_Materials()
					my_file_clean_materials.Multi_Materials()
					
					-----------------------------------------------------------------------------------------------------------------------------------------------------
					--PREPARE OBJECTS FOR MERGING: 
					
					--Initialize file_prepare_objects:
					my_file_prepare_objects = file_prepare_objects all_objects
					
					--Update meshes:
					Update_Meshes #(all_objects, nonInstances, duplicateObjects, singleObjects)
					
					--Make all objects unique:
					my_file_prepare_objects.Make_Unique()
					
					-----------------------------------------------------------------------------------------------------------------------------------------------------
					--DETACH OBJECTS WITH MUTLIMATERIAL INTO SEPARATE OBJECTS FOR EACH FACE ID:
					
					if chkBox_breakMultiMats.checked do
					(
						--Update meshes:
						Update_Meshes #(all_objects, nonInstances, duplicateObjects, singleObjects)
						
						--Collect objects with multimaterials:
						the_objects = (for obj in all_objects where classOf obj.material == Multimaterial collect obj)
						
						--Initialize the file_separate_faceIDs struct:
						my_file_separate_faceIDs = file_separate_faceIDs the_objects my_file_collect_materials.allMaterials my_file_collect_materials.allMaterials_names all_objects
						
						--Run the operation:
						my_file_separate_faceIDs.Separate_Operation()
						
					)
					
					-----------------------------------------------------------------------------------------------------------------------------------------------------
					--MERGE OBJECTS WITH SAME MATERIAL:
					
					if chkBox_mergeByMat.checked do
					(
						--Update meshes:
						Update_Meshes #(all_objects)
						
						--Collect objects that does not have multimaterials:
						the_objects = (for obj in all_objects where classOf obj.material != Multimaterial collect obj)

						--Initialize file_merge_geometry:
						my_file_merge_geometry = file_merge_geometry the_objects my_file_collect_materials.allMaterials my_file_collect_materials.allMaterials_names all_objects
						
						--Merge objects:
						my_file_merge_geometry.Merge_Operation()
					)
					
					-----------------------------------------------------------------------------------------------------------------------------------------------------
					--FINAL MESH UPDATE:
					
					Update_Meshes #(all_objects)
					
					-----------------------------------------------------------------------------------------------------------------------------------------------------
				)--END If continue_operation
				
			)--END with redraw off
			
			-----------------------------------------------------------------------------------------------------------------------------------------------------
			--AFTER-OPERATIONS:
			
			--Redraw scene:
			completeRedraw()
			select all_objects
			setArrowCursor()	
			
			--If requested, save and close scene. Otherwise, just messagebox done:
			if continue_operation do
			(
				if  rBtn_saveExit.state == 2 or rBtn_saveExit.state == 3 do saveMaxFile(txt_savePath.text)
				if  rBtn_saveExit.state == 1 or rBtn_saveExit.state == 2 do messagebox "Done"
				if  rBtn_saveExit.state == 3 do quitMax #noPrompt
			)
			
			-----------------------------------------------------------------------------------------------------------------------------------------------------
			
		)--END btn_execute
	)--END rollout	
)--END Interface
