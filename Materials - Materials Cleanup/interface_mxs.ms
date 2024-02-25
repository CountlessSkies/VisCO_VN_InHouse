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
	
	--Get Collect_Materials struct from "collect_materials.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "collect_materials.ms" --Combines directory and filename to create a path
	file_collect_materials = fileIn path_script
	
	--Get duplicate_materialNames struct from "duplicate_materialNames.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "duplicate_materialNames.ms" --Combines directory and filename to create a path
	file_duplicate_materialNames = fileIn path_script
	
	--Get MultiMat_To_SingleMat struct from "multiMat_To_SingleMat.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "multiMat_To_SingleMat.ms" --Combines directory and filename to create a path
	file_multiMat_To_SingleMat = fileIn path_script
	
	--Get Converge struct from "converge.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "converge.ms" --Combines directory and filename to create a path
	file_converge = fileIn path_script
	
	--Get condense_multimats struct from "condense_multimats.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "condense_multimats.ms" --Combines directory and filename to create a path
	file_condense_multimats = fileIn path_script
	
	--Get Clean_Materials struct from "clean_materials.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "clean_materials.ms" --Combines directory and filename to create a path
	file_clean_materials = fileIn path_script
	
	------------------------------------------------------------------------------------------------------------------------------------------
	rollout rollout_main "Materials Cleanup"
	(
		group "Object Selection"
			(
				checkBox chkBox_inclSelected "Include selected objects" checked:true
				checkBox chkBox_inclNotSelected "Include non-selected objects" offset:[175,-20] checked:false
				checkBox chkBox_inclVisible "Include visible objects" checked:true
				checkBox chkBox_inclHidden "Include hidden objects" offset:[175,-20] checked:false
				checkBox chkBox_inclNotFrozen "Include non-frozen objects" checked:true
				checkBox chkBox_inclFrozen "Include frozen objects" offset:[175,-20] checked: false
				label lbl_1 ""
			)
			
		group "Additional operations: "
			(
				checkBox chkBox_condense "Condense multimaterials" checked: True \
					tooltip: "Objects that has a multimaterial, will get a new, condensed multimaterial with only the submaterials that it needs"
				checkBox chkBox_converge "Converge submaterials over" checked: true \
					tooltip: "If a single submaterial occupies more than this percent of faces on an object, promote the submaterial to a separate material and assign it to the object"
				spinner spn_convergeValue "" type:#integer range: [0,100,99] scale: 1 fieldwidth: 28 align:#left offset:[156,-19]
				label lbl_percent "% into a single material" align:#left offset:[199,-20] enabled: true
				label lbl_2 ""
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
				button btn_execute "Cleanup Materials" Align: #left
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
			
			undefinedMatName = "undefined" --This is the name that is used for undefined materials
			
			with redraw off
			(
				-----------------------------------------------------------------------------------------------------------------------------------------------------
				--ERROR CHECKING:
				
				--Make an instance of the error checking struct:
				my_file_error_check = file_error_check all_objects rBtn_saveExit.state txt_savePath.text
				
				local continue_operation = true--Stops the script from running if set to false
				
				--Check if save file path is valid:
				if continue_operation do if ( my_file_error_check.SavePath_Valid() ) != true do continue_operation = false
				
				--Check that all objects that are instances of each other, has the same material:
				if continue_operation do if ( my_file_error_check.Same_Mat_On_Instances() ) != true do continue_operation = false
				
				--Chech that there are no modifiers that can interfere with material IDs on the object:
				if continue_operation do if ( my_file_error_check.Forbidden_Modifiers() ) != true do continue_operation = false
				
				-----------------------------------------------------------------------------------------------------------------------------------------------------
				--MAIN OPERATION:
				
				if continue_operation do
				(
					--Update meshes:
					Update_Meshes #(all_objects, nonInstances, duplicateObjects, singleObjects)
					
					--COLLECT MATERIALS:
					
					--Initialize material collection from all_objects:
					my_file_collect_materials = file_collect_materials all_objects undefinedMatName
					
					--Collect materials:
					my_file_collect_materials.Collect_Materials()
					
					-----------------------------------------------------------------------------------------------------------------------------------------------------
					--CONVERT MULTIMAT TO SINGLEMAT WHERE POSSIBLE:
					
					--Initialize multiMat_To_SingleMat struct:
					my_file_multiMat_To_SingleMat = \
					file_multiMat_To_SingleMat all_objects my_file_collect_materials.allMaterials my_file_collect_materials.allMaterials_names undefinedMatName
					
					if chkBox_condense.checked == true do 
					(
						--Update meshes:
						Update_Meshes #(all_objects, nonInstances, duplicateObjects, singleObjects)
						
						--Run the function to condense multiMats to singleMats where possible: (This is to reduce the need to work on faceID´s if it can be avoided)
						my_file_multiMat_To_SingleMat.FN_MultiMat_To_SingleMat()
					)
					
					
					-----------------------------------------------------------------------------------------------------------------------------------------------------
					--CONVERGE MUTLIMATERIALS:
					
					--Initialize converge struct:
					my_file_converge = file_converge nonInstances spn_convergeValue.value
					
					if chkBox_converge.checked == true do
					(
						--Update meshes:
						Update_Meshes #(all_objects, nonInstances, duplicateObjects, singleObjects)
						
						--Run the function to converge multimaterials:
						my_file_converge.Converge_MultiMats() 
					)
					
					-----------------------------------------------------------------------------------------------------------------------------------------------------
					--CONDENSE MULTIMATERIALS:
					
					--Initialize the condense struct:
					my_file_condense_multimats = file_condense_multimats nonInstances my_file_collect_materials.allMaterials my_file_collect_materials.allMaterials_names undefinedMatName
					
					if chkBox_condense.checked == true do
					(
						--Update meshes:
						Update_Meshes #(all_objects, nonInstances, duplicateObjects, singleObjects)
						
						--Run the collect function:
						my_file_condense_multimats.Collect_MultiMats()
						
						--Run the condense function:
						my_file_condense_multimats.Condense_MultiMats()
						
						--Run the make multiMats function:
						my_file_condense_multimats.Make_MultiMats()
						
						--Run the change faceIDs function:
						my_file_condense_multimats.Change_FaceIDs()
						
						--Run the apply materials function:
						my_file_condense_multimats.Apply_MultiMats()
						
						--Run the function to condense multiMats (a second time). This is done since the multiMaterials have been condensed:
						my_file_multiMat_To_SingleMat.FN_MultiMat_To_SingleMat()
						
						--Run the debug:
						--my_file_condense_multimats.Debug()
					)
					
					-----------------------------------------------------------------------------------------------------------------------------------------------------
					--CLEAN UP MATERIALS
					--(Make sure all scene materials with the same name, is the same material instance)
					
					--Initialize clean_materials struct:
					my_file_clean_materials = file_clean_materials all_objects my_file_collect_materials.allMaterials my_file_collect_materials.allMaterials_names undefinedMatName
					
					--Update meshes:
					Update_Meshes #(all_objects, nonInstances, duplicateObjects, singleObjects)
					
					--Run the functions to clean up object materials:
					my_file_clean_materials.No_Materials()
					my_file_clean_materials.Single_Materials()
					my_file_clean_materials.Multi_Materials()
					if chkBox_condense.checked == true do my_file_clean_materials.Rename_MultiMat_Namelist()
					
					-----------------------------------------------------------------------------------------------------------------------------------------------------
					--REMOVE DUPLICATE MATERIAL NAMES IN SCENE:
					
					--Initialize file_duplicate_materialNames struct:
					my_file_duplicate_materialNames = file_duplicate_materialNames all_objects
					
					--Collect materials from selected objects:
					my_file_duplicate_materialNames.Collect_SelectedMaterials()
					
					--Compare material names with other scene objects with single materials:
					my_file_duplicate_materialNames.Remove_Duplicates_SingleMat()
					
					--Compare material names with other scene objects with multimaterials:
					my_file_duplicate_materialNames.Remove_Duplicates_MultiMat()
					
					-----------------------------------------------------------------------------------------------------------------------------------------------------
					--FINAL MESH UPDATE:
					
					Update_Meshes #(all_objects, nonInstances, duplicateObjects, singleObjects)
					
				)--END If continue_operation
				
			)--END with redraw off
			
			-----------------------------------------------------------------------------------------------------------------------------------------------------
			--AFTER-OPERATIONS:
			
			--Redraw scene:
			completeRedraw()
			select preSelObjs
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
