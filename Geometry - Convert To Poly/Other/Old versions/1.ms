(--START script
	
	--SCRIPT GLOBAL VARIABLES:
	convertedObjects = #()
	
	--START Function
	fn fn_Convert obj convertInstanced deleteModifiers =
	(
		if (findItem convertedObjects obj) == 0 do
		(
			--Objects that are instances of the original object is stored in "&InstancesArray"-array:
			InstanceMgr.GetInstances obj &Instances
			modifiersCount = obj.modifiers.count
			InstancesArray = #()
			append convertedObjects obj
			
			if Instances.count == 1 do 
			(
				if deleteModifiers == true and modifiersCount >0 do for i = modifiersCount to 1 by -1 do deleteModifier obj i
				convertToPoly obj
			)
			
			--The script runs on every instanced object:
			if Instances.count >1 and convertInstanced == true do 
			(
				if deleteModifiers == true and modifiersCount >0 do for i = modifiersCount to 1 by -1 do deleteModifier obj i
				convertToPoly obj
				for i = instances do append InstancesArray i
			)
			
			for i = InstancesArray where i != obj do 
			(
				--modifiersCount gets converted to include the number of modifiers on the current instance object:
				modifiersCount = i.modifiers.count
				
				if modifiersCount >0 do for j = modifiersCount to 1 by -1 do deleteModifier i j
				convertToPoly i
				i.baseObject = obj.baseObject
				append convertedObjects i
			)
		) 
	)
	--END Functions

	rollout rollout_convertToEditPoly "Convert to edit poly"
	(
		--User Interface
		checkbox chk_deleteModifiers "Delete modifiers (Unchecked = modifiers baked)"
		checkbox chk_convertInstanced "Convert instanced objects" checked: true
		checkbox chk_workOnEditPoly "Include edit poly class objects" checked:true
		checkbox chk_includeSplines "Include spline objects"
		checkbox chk_includeHidden "Include hidden objects" checked: true
		checkbox chk_includeFrozen "Include frozen objects" checked: true
		checkbox chk_selectionOnly "Selected objects only"
		group "Warnings"
		(
			label lbl_warning_1 "All modifiers above the reference line"
			label lbl_warning_2 "on reference objects will be deleted."
		)
		button btn_convert "Convert"
		Group "Info"
		(
			label lbl_info "Cameron Sense AS" --Please keep this :)
			label lbl_info_2 "2013"
		)
		--User interface END
		
		
		on btn_convert pressed do
		(--btn_convertAll START
			undo "Convert to poly" on
			(--Undo START
				setWaitCursor()
				with reDraw off
				(--Redraw off
					--Fill objectsToConvert with objects that will be converted
					objectsToConvert = #()
					for obj = objects where \
					(superClassOf obj == GeometryClass or superClassOf obj == shape) and \
					(classOf obj != Targetobject) and \
					(obj.isHidden == false or chk_includeHidden.checked == true) and \
					(obj.isFrozen == false or chk_includeFrozen.checked == true) and \
					(superClassOf obj != shape or chk_includeSplines.checked == true) and \
					(obj.isSelected == true or chk_selectionOnly.checked == false) and \
					(classOf obj != Editable_Poly or chk_workOnEditPoly.checked == true) do append objectsToConvert obj
					
					--Holds the selected objects in selectionArray so that they can be deselected while the script runs
					selectionArray = (for i = selection collect i)
					deSelect objects
					
					for obj = objectsToConvert do fn_Convert obj chk_convertInstanced.checked chk_deleteModifiers.checked
					
					--Array that contains the list over objects that are converted is emptied:
					free convertedObjects
					
					--Selects objects that was selected before the script ran:
					select selectionArray
					free selectionArray
				)--ReDraw off END
				redrawViews()
				setArrowCursor()
			)--Undo END
		)--btn_convertAll END
	)
	createDialog rollout_convertToEditPoly 300 300
)--END script