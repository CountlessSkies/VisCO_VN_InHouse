(--START Interface
	
	
	------------------------------------------------------------------------------------------------------------------------------------------
	--Get Selection struct from "selection.ms":
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "selection.ms" --Combines directory and filename to create a path
	file_selection = fileIn path_script
	
	--Get Error_Check struct from error_check.ms:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "error_check.ms" --Combines directory and filename to create a path
	file_error_check = fileIn path_script
	
	--Get Repository struct from repository.ms:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "repository.ms" --Combines directory and filename to create a path
	file_Repository = fileIn path_script
	
	--Get Detach_Elements struct from Detach_Elements.ms:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "Detach_Elements.ms" --Combines directory and filename to create a path
	file_Detach_Elements = fileIn path_script
	
	------------------------------------------------------------------------------------------------------------------------------------------
	rollout rollout_main "Detach Elements"
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
			
		group "Settings"
			(
				checkBox chkBox_collapseModifiers "Collapse modifier stack" checked: true tooltip: "Collapse the stack if modifiers causes problems"
				label lbl_2 ""
			)
			
		group "Save Settings"
			(
				radioButtons rBtn_undo "Undo Level:" labels:#("None", "Hold") align:#left default: 2
				radiobuttons rBtn_saveExit "After Completion:" labels:#("Nothing", "Save", "Save and Exit") align:#left columns:3 offsets:#([0,0], [0,0], [-20,0]) offset:[180,-35]
				editText txt_savePath "Save Path:" fieldWidth:360 enabled:False
				button btn_browse "Browse" align:#left offset:[425,-25] enabled: False
				
			)
		
		group "Execute"
			(
				button btn_execute "Detach Elements" Align: #left
			)
			
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
			setWaitCursor()
			
			with redraw off
			(
				----------------------------------------------------------------------------------------------------------------
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
				
				----------------------------------------------------------------------------------------------------------------
				--MAKE STRUCT INSTANCES:
				
				my_file_error_check = file_error_check rBtn_saveExit.state txt_savePath.text
				my_file_Repository = file_Repository()
				my_file_Detach_Elements = file_Detach_Elements all_objects
				
				----------------------------------------------------------------------------------------------------------------
				--PREPARE SCENE:
				
				--Deselect objects:
				local preSelObjs = (for i in selection collect i)
				clearSelection()
				
				--Set correct undo setting and run the functions
				if rBtn_undo.state == 2 do holdMaxFile()
				clearUndoBuffer()
			
			----------------------------------------------------------------------------------------------------------------
				--ERROR CHECKING:
				local continue_operation = true--Stops the script from running if set to false
				
				--Go through error checks:
				if continue_operation and ( my_file_error_check.SavePath_Valid() ) != true do continue_operation = false
				
				--Select previously selected objects if the operation does not continue:
				if continue_operation != true do select preSelObjs
					
				----------------------------------------------------------------------------------------------------------------
				if continue_operation == true do --Run the main operation
				(
					--Update meshes:
					for collection in #(all_objects, nonInstances, duplicateObjects, singleObjects) do my_file_Repository.Update_Meshes collection
					
					--Prepare objects:
					my_file_Repository.Make_Unique all_objects chkBox_collapseModifiers.checked
					
					--Detach elements:
					my_file_Detach_Elements.Detach_Elements()
					
					--Update meshes after detaching:
					my_file_Repository.Update_Meshes all_objects
					
				)--END continue_operation == true
				
				----------------------------------------------------------------------------------------------------------------
				
			)--END with redraw off
			
			
			completeRedraw()
			
			
			--If requested, save and close scene. Otherwise, just messagebox done:
			if continue_operation do
			(
				if  rBtn_saveExit.state == 2 or rBtn_saveExit.state == 3 do saveMaxFile(txt_savePath.text)
				if  rBtn_saveExit.state == 2 do messagebox "Done"
				if  rBtn_saveExit.state == 3 do quitMax #noPrompt
			)
			
			--Select all new objects that was worked on:
			select all_objects
			
			setArrowCursor()
			
			
			----------------------------------------------------------------------------------------------------------------
			
			
			
		)--END btn_execute
	)--END rollout	
)--END Interface
