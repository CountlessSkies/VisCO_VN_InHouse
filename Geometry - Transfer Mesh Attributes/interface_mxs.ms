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
	
	
	--Get FaceIDs struct from faceIDs.ms:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "faceIDs.ms" --Combines directory and filename to create a path
	file_faceIDs = fileIn path_script
	
	--Get struct UVW_Mapping from uvw_mapping.ms:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "uvw_mapping.ms" --Combines directory and filename to create a path
	file_uvw_mapping = fileIn path_script
	
	--Get struct Materials from materials.ms:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "materials.ms" --Combines directory and filename to create a path
	file_materials = fileIn path_script
	
	
	------------------------------------------------------------------------------------------------------------------------------------------
	local from_objects = #() --Contain objects that attributes are taken from
	local to_objects = #() --Contain objects that attributes are transfered to
	
	------------------------------------------------------------------------------------------------------------------------------------------
	rollout rollout_main "Transfer Mesh Attributes"
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
				button btn_transfer_from "Transfer From" align: #left
				button btn_transfer_to "Transfer To" align: #left offset:[175,-26]
			)
			
		group "Transfer attributes"
			(
				radioButtons rBtn_opType "" labels:#("Face ID큦 ", "UVW mapping ", "Materials ") align:#left default: 3
				spinner spn_mapChannel "UVW Channel: " type:#integer range: [1,99,1] fieldwidth: 25 align:#left offset:[275,-19]
			)
			
		group "Runtime Settings"
			(
				radioButtons rBtn_undo "Undo Level:" labels:#("None", "Hold") align:#left default: 2
				radiobuttons rBtn_saveExit "After Completion:" labels:#("Nothing", "Save", "Save and Exit") align:#left columns:3 offsets:#([0,0], [0,0], [-20,0]) offset:[180,-35]
				editText txt_savePath "Save Path:" fieldWidth:360 enabled:False
				button btn_browse "Browse" align:#left offset:[425,-25] enabled: False
				
			)
		
		group "Execute"
			(
				button btn_execute "Execute" Align: #left
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
		
		on rBtn_opType changed state do
		(
			if state == 1 do
			(
				spn_mapChannel.enabled = false
			)
			if state == 2 or state == 3 do
			(
				spn_mapChannel.enabled = true
			)
		)

		on btn_browse pressed do 
		(
			filePath = getSaveFileName()
			if filePath == undefined then filePath = txt_savePath.text
			txt_savePath.text=filePath
		)
			
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		
		on btn_transfer_from pressed do
		(
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
			
			--Save selection as allObjects:
			from_objects = my_selection.allObjects
		)
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		on btn_transfer_to pressed do
		(
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
			
			--Save selection as allObjects:
			to_objects = my_selection.allObjects
		)
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		on btn_execute pressed do
		(
			--PREPARE SCENE:
			
			setWaitCursor()
			
			--Deselect objects:
			local preSelObjs = (for i in selection collect i)
			clearSelection()
			
			--Update meshes before script:
			for obj in from_objects do (update obj)
			for obj in to_objects do (update obj)
			
			--Set correct undo setting and run the functions
			if rBtn_undo.state == 2 do holdMaxFile()
			clearUndoBuffer()
			
			----------------------------------------------------------------------------------------------------------------
			with redraw off
			(
				--ERROR CHECKING:
				
				--Make an instance of the error checking struct, and give it from_objects and to_objects. This will be used for different checks
				my_file_error_check = file_error_check from_objects to_objects rBtn_saveExit.state txt_savePath.text rBtn_opType.state
				
				local continue_operation = true--Stops the script from running if set to false
				
				--Check if save file path is valid:
				if continue_operation do if ( my_file_error_check.SavePath_Valid() ) != true do continue_operation = false
				
				--Check that no objects within the same set has identical names:
				if continue_operation do if (my_file_error_check.No_Identical_Names() ) != true do continue_operation = false
				
				--Check that no object is in both object sets (from_objects and to_objects):
				if continue_operation do if ( my_file_error_check.Overlapping_ObjSets() ) != true do continue_operation = false
				
				--Check that all object names are in both from_objects and to_objects:
				if continue_operation do if ( my_file_error_check.All_Names_In_Sets() ) != true do continue_operation = false
				
				--Check if its the same number of objects in both from_objects and to_objects:
				if continue_operation do if ( my_file_error_check.Count_Objects() ) != true do continue_operation = false
				
				--Check that objects with same name is of the same mesh type (poly or mesh):
				if continue_operation do if ( my_file_error_check.Same_Mesh_Class() ) != true do continue_operation = false
				
				--Check that objects with the same name has the same face count:
				if continue_operation do if ( my_file_error_check.Same_Face_Count() ) != true do continue_operation = false
				
				
				----------------------------------------------------------------------------------------------------------------
				--RUN THE OPERATION:
				if continue_operation do
				(
					
					
					
					--Transfer face ID:
					if rBtn_opType.state == 1 do
					(
						--Loop through each object
						for from_object in from_objects do
						(
							--Instance of face ID class. It stores data like face numbers, face IDs etc.
							my_file_faceIDs = file_faceIDs()
							
							--Get face ID큦 and store them in my_file_faceIDs face_array and id_array:
							my_file_faceIDs.Get_FaceIDs from_object
							
							
							--Set face ID큦 from my_file_faceIDs face_array and id_array:
							for to_object in to_objects where to_object.name == from_object.name do
							(
								--Run function to SET faceIDs at object:
								my_file_faceIDs.Set_FaceIDs to_object
							)--END loop through to_objects
						)--END loop through from_objects
					)--END transfer face IDs (chkBox_faceIDs)
					
					
					
					
					
					--Transfer UVW mapping:
					if rBtn_opType.state == 2 do
					(
						--Loop through each object
						for from_object in from_objects do
						(
							
							my_file_uvw_mapping = file_uvw_mapping spn_mapChannel.value
							
							my_file_uvw_mapping.Get_UVW from_object
							
							--Set face UVW큦 from my_file_faceIDs face_array and id_array:
							for to_object in to_objects where to_object.name == from_object.name do
							(
								
								my_file_uvw_mapping.Set_UVW to_object
								
							)--END loop through to_objects
							
							
							
						)--END loop through from_objects
					)--END transfer UVW mapping
					
					
					
					
					
					--Transfer Materials:
					if rBtn_opType.state == 3 do
					(
						--Loop through each object
						for from_object in from_objects do
						(
							
							my_file_materials = file_materials undefined
							
							my_file_materials.Get_Material from_object
							
							--Set face materials from my_file_materials:
							for to_object in to_objects where to_object.name == from_object.name do
							(
								my_file_materials.Set_Material to_object
								
							)--END loop through to_objects
							
							
							
						)--END loop through from_objects
					)--END Transfer Materials
					
					
					
					
				)--END run operation
				
				----------------------------------------------------------------------------------------------------------------	
				
				
				
				
				
			)--END with redraw off
			
			----------------------------------------------------------------------------------------------------------------
			--AFTER-OPERATIONS:
			
			--Update meshes after script:
			for obj in from_objects do (update obj)
			for obj in to_objects do (update obj)
			
			--Selects objects that was deselected during the script run:
			select preSelObjs
			
			--Redraw scene:
			completeRedraw()
			setArrowCursor()	
			
			--If requested, save and close scene. Otherwise, just messagebox done:
			if continue_operation do
			(
				if  rBtn_saveExit.state == 2 or rBtn_saveExit.state == 3 do saveMaxFile(txt_savePath.text)
				if  rBtn_saveExit.state == 1 or rBtn_saveExit.state == 2 do messagebox "Done"
				if  rBtn_saveExit.state == 3 do quitMax #noPrompt
			)
			
			----------------------------------------------------------------------------------------------------------------
			
			
			
		)--END btn_execute
	)--END rollout	
)--END Interface
