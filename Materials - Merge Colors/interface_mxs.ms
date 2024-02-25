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
	
	--Get Collected_Materials struct from "collected_materials.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "collected_materials.ms" --Combines directory and filename to create a path
	file_collected_materials = fileIn path_script
	
	--Get MergeMats struct from "mergeMats.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "mergeMats.ms" --Combines directory and filename to create a path
	file_mergeMats = fileIn path_script

	------------------------------------------------------------------------------------------------------------------------------------------
	rollout rollout_main "Merge Colors"
	(
		group "Object Selection"
			(
				checkBox chkBox_inclSelected "Include selected objects" checked:true
				checkBox chkBox_inclNotSelected "Include non-selected objects" offset:[175,-20] checked:false
				checkBox chkBox_inclVisible "Include visible objects" checked:true
				checkBox chkBox_inclHidden "Include hidden objects" offset:[175,-20] checked:false
				checkBox chkBox_inclNotFrozen "Include non-frozen objects" checked:true
				checkBox chkBox_inclFrozen "Include frozen objects" offset:[175,-20] checked:false
				label lbl_empty_1 ""
			)
			
		group "Settings: "
			(
				checkBox chkBox_do_singleMaterials "Include Single Materials" checked: True \
					tooltip: "Include single materials"
				checkBox chkBox_do_multiMaterials "Include Multimaterials" offset:[175,-19] checked: True \
					tooltip: "Include multimaterials"
				label lbl_mergeValue_1 "Merge colors over " align:#left offset:[0,0] enabled: true \
					tooltip: "Colors with a similiarity above this % value will be merged"
				spinner spn_mergeValue "" type:#integer range: [0,100,90] scale: 1 fieldwidth: 28 align:#left offset:[95,-19] \
					tooltip: "Colors with a similiarity above this % value will be merged"
				label lbl_mergeValue_2 " % similarity" align:#left offset:[140,-19] enabled: true
			)
			
			
		group "Runtime Settings"
			(
				radioButtons rBtn_undo "Undo Level:" labels:#("None", "Hold") align:#left default: 2
				radiobuttons rBtn_saveExit "After Completion:" labels:#("Nothing", "Save", "Save and Exit") align:#left columns:3 offsets:#([0,0], [0,0], [-20,0]) offset:[180,-35]
				editText txt_savePath "Save Path:" fieldWidth:360 enabled:False
				button btn_browse "Browse" align:#left offset:[425,-25] enabled: False
				label lbl_empty_4 ""
				
			)
				button btn_execute "Merge" Align: #left
			
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
			
			do_singleMaterials = chkBox_do_singleMaterials.checked
			do_multiMaterials = chkBox_do_multiMaterials.checked
			
			--Initialize the selection struct:
			my_selection = file_selection \
			includeSelected includeNotSelected includeVisible includeHidden \
			includeNotFrozen includeFrozen do_singleMaterials do_multiMaterials
			
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
			local preSelObjs = (for i in selection collect i) --Collects selected materials so that they can be selected again at the end
			clearSelection()
			
			--Close material editor:
			local matEditorIsOpen = MatEditor.isOpen() --Collects material editor open status, so it can be set to the same again at the end
			MatEditor.Close() 
			
			--Variable that will indicate if the script should continue or stop:
			local continue_operation = true
			
			with redraw off
			(
				
				--UPDATE MESHES:
				Update_Meshes #(all_objects)
				
				-----------------------------------------------------------------------------------------------------------------------------------------------------
				--COLLECT MATERIALS:
				
				--Initialize material collection from all_objects:
				my_file_collected_materials = file_collected_materials all_objects
				
				--Collect materials:
				my_file_collected_materials.Collect_Materials()
				
				-----------------------------------------------------------------------------------------------------------------------------------------------------
				--ERROR CHECKING:
				
				--Make an instance of the error checking struct:
				my_file_error_check = file_error_check all_objects rBtn_saveExit.state txt_savePath.text my_file_collected_materials.allMaterials
				
				--Check if save file path is valid:
				if continue_operation do if ( my_file_error_check.SavePath_Valid() ) != true do continue_operation = false
				
				--Check if all material classes are valid:
				if continue_operation do if ( my_file_error_check.Approved_MatClasses() ) != true do continue_operation = false
				
				-----------------------------------------------------------------------------------------------------------------------------------------------------
				--MAIN OPERATION:
				
				if continue_operation do
				(
					--Initialize MergeMats:
					my_file_mergeMats = file_mergeMats all_objects my_file_collected_materials.allMaterials spn_mergeValue.value
					
					my_file_mergeMats.SetSameColor()
					my_file_mergeMats.MergeByColor()
				)
				
				-----------------------------------------------------------------------------------------------------------------------------------------------------
				--MAKE MATERIAL COUNT PRINT STATEMENT:
				
				if continue_operation do
				(
					org_matCount = my_file_collected_materials.allMaterials.count
					new_matCount = my_file_mergeMats.reducedMatArray.count
					difference_matCount = org_matCount - new_matCount
					
					print_message = ""
					print_message += "Original materials count was " + (org_matCount as string) + " materials \n"
					print_message += "New materials count is " + (new_matCount as string) + " materials \n"
					print_message += "Materials reduced by " + (difference_matCount as string) + " materials"
				)
				
				-----------------------------------------------------------------------------------------------------------------------------------------------------
				
			)--END with redraw off
			
			-----------------------------------------------------------------------------------------------------------------------------------------------------
			--AFTER-OPERATIONS:
			
			--Redraw scene:
			completeRedraw()
			select preSelObjs
			if matEditorIsOpen do MatEditor.Open()
			setArrowCursor()	
			
			--If requested, save and close scene. Otherwise, just messagebox done:
			if continue_operation do
			(
				if  rBtn_saveExit.state == 2 or rBtn_saveExit.state == 3 do saveMaxFile(txt_savePath.text)
				if  rBtn_saveExit.state == 1 or rBtn_saveExit.state == 2 do messagebox print_message
				if  rBtn_saveExit.state == 3 do quitMax #noPrompt
			)
			
			-----------------------------------------------------------------------------------------------------------------------------------------------------
			
		)--END btn_execute
	)--END rollout	
)--END Interface
