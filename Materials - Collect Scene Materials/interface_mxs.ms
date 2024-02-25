(--START Interface

	--Get Dict_From_File struct:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "dict_from_file.ms" --Combines directory and filename to create a path
	file_dict_from_file = fileIn path_script
	
	--Get Arr_From_File struct:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "arr_from_file.ms" --Combines directory and filename to create a path
	file_arr_from_file = fileIn path_script
	
	--Get Main struct from main.ms:
	path_thisFile = getSourceFileName() --Gets the full path for currently running script
	dir_script = getFilenamePath path_thisFile --Strips filename, so you get only the directory of the currently running script
	path_script = pathConfig.appendPath dir_script "main.ms" --Combines directory and filename to create a path
	file_main = fileIn path_script
	
	
	--------------------------------------------------------------------------------------------------------------------------------------------
	--Inventor creates a bunch of materials that isn´t real materials, they are just grey. They are named "material #[number here]"
	--nonMatLUT contains a list of material names that should be lumped together as one. "material #" is added as default
	--The delimiter used between material names is also set here
	local mergeLUT = "" --variable created
	--mergeLUT += "material #" --default names added (currently commented out due to "material #" no longer needed to be collected)
	local delim_mergeLUT = "," --delimiter
	local mergeLUT_txt = ("Use " + delim_mergeLUT + " as string separator") --Text for lbl_nonMatLUT 
	--------------------------------------------------------------------------------------------------------------------------------------------
	
	
	--Interface:
	rollout rollout_main "Collect Scene Materials"
	(
		group "Object Selection"
		(
			checkBox chkBox_inclSelected "Include selected objects" checked:true
			checkBox chkBox_inclNotSelected "Include non-selected objects" offset:[175,-20] checked:false
			checkBox chkBox_inclVisible "Include visible objects" checked:true
			checkBox chkBox_inclHidden "Include hidden objects" offset:[175,-20] checked:false
			checkBox chkBox_inclNotFrozen "Include non-frozen objects" checked:true
			checkBox chkBox_inclFrozen "Include frozen objects" offset:[175,-20] checked: false
		)
		group "Settings"
		(
			button btn_openRollout_mergeLUT "Merge Names LUT" align:#left
			label lbl_firstSlot "First slot: " offset:[-100,-20]
			dropdownlist dropList_firstSlot items:#("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24") selection: 1 width: 40 height:25 offset:[160,-22]
			label lbl_lastSlot "Last slot: " offset:[0,-23]
			dropdownlist dropList_lastSlot items:#("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24") selection: 24 width: 40 height:25 offset:[260,-22]
			label lbl_maxSubSlots "Max subSlots: " offset:[120,-23]
			dropdownlist dropList_maxSubSlots items:#("50", "100", "150", "200", "250", "300", "350", "400", "450", "500") selection: 4 width: 50 height:25 offset:[390,-22]
		)
		group "Runtime Settings"
		(
			radioButtons rBtn_undo "Undo Level:" labels:#("None", "Hold", "Undo") align:#left default: 2
			radiobuttons rBtn_saveExit "After Completion:" labels:#("Nothing", "Save", "Save and Exit") align:#left columns:3 offsets:#([0,0], [0,0], [-20,0]) offset:[180,-35]
			editText txt_savePath "Save Path:" fieldWidth:360 enabled:False
			button btn_browse "Browse" align:#left offset:[425,-25] enabled: False
			
		)
		group "Execute"
		(
			button btn_execute "Execute" Align: #left
		)
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		--Open non-materials LUT file:
		rollout rollout_mergeLUT " Merge Material Names"
		(
			label lbl_mergeLUT mergeLUT_txt
			editText txt_mergeLUT height:500 fieldWidth:250 align:#center text: mergeLUT
			button btn_save_mergeLUT "Save"
			on btn_save_mergeLUT pressed do 
			(
				mergeLUT = txt_mergeLUT.text
				try (destroyDialog rollout_mergeLUT) catch()
			)
		)
		on btn_openRollout_mergeLUT pressed do createDialog rollout_mergeLUT 300 575
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
		on dropList_firstSlot selected my_selection do
		( 
			dropList_lastSlot.items = (for i in my_selection to 24 collect i as string)
			dropList_lastSlot.selection = dropList_lastSlot.items.count
		)
		
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		on btn_execute pressed do
		(
			--Check if file path for save is valid:
			if \
			(rBtn_saveExit.state == 2 or rBtn_saveExit.state == 3) and \
			((dotnetclass "System.IO.Directory").exists (getFilenamePath(txt_savePath.text))) == False \
			then MessageBox "Not a valid save path"
			else
			(
				--Make dictionary with settings:
				collMats_dict = Dictionary (#string) -- empty dictionary of the specified type
				
				collMats_dict["inclSelected"] = chkBox_inclSelected.checked
				collMats_dict["inclNotSelected"] = chkBox_inclNotSelected.checked
				collMats_dict["inclVisible"] = chkBox_inclVisible.checked
				collMats_dict["inclHidden"] = chkBox_inclHidden.checked
				collMats_dict["inclNonFrozen"] = chkBox_inclNotFrozen.checked
				collMats_dict["inclFrozen"] = chkBox_inclFrozen.checked
				
				collMats_dict["undo"] = rBtn_undo.state
				collMats_dict["firstSlot"] = dropList_firstSlot.items[dropList_firstSlot.selection]
				collMats_dict["lastSlot"] = dropList_lastSlot.items[dropList_lastSlot.selection]
				collMats_dict["maxNumSubSlots"] = dropList_maxSubSlots.items[dropList_maxSubSlots.selection]
				
				collMats_dict["dir_proj"] = "undefined"
				collMats_dict["name_proj"] = "undefined"
				collMats_dict["path_proj"] = "undefined"
				collMats_dict["save"] = (if rBtn_saveExit.state == 2 or rBtn_saveExit.state == 3 then True else False)
				collMats_dict["close"] = (rBtn_saveExit.state == 3)
				collMats_dict["path_logFile"] = "undefined"
				collMats_dict["newName_proj"] = "undefined"
				collMats_dict["newPath_proj"] = txt_savePath.text
				
				--Make dictionary to text and put it in a file:
				file_dict_from_file.make_file collMats_dict "settings.ini" "="
				
				--Make nonMatLUT material names list and save as a text file:
				file_arr_from_file.make_file mergeLUT "mergeLUT.txt"
				
				--Run main:
				file_main.run()
				
				
			) --END valid file path check
		)
		
	)--END rollout


)--END Interface