(
	--Variables:
	local scriptName = "Body Object Detail Level"
	local levelList = #("coarse", "medium", "fine")
	local levelListHeight = 3
	
	--Arrays:
	local allObjects = #()
	local nonInstancesArray = #()
	local duplicateObjectsArray = #()
	local workedObjectsArray = #()

	--START interface
	rollout rollout_main scriptName
	(
		group "Objects included (an object must qualify ALL selected criteria)"
		(
			checkBox chkBox_includeSelected "Selected" checked:true
			checkBox chkBox_includeNotSelected "Non-selected" checked: false
			checkBox chkBox_includeHidden "Hidden" checked: false
			checkBox chkBox_includeVisible "Visible" checked:true
			checkBox chkBox_includeFrozen "Frozen" checked: false
			checkBox chkBox_includeNotFrozen "Non-frozen" checked:true
		)
		group "Options for list of worked objects"
		(
			checkBox chkBox_includeWorkedObjects "Change detail level on objects already worked on"
			checkBox chkBox_excludeFromWorkedObjects "Do not save in worked objects list (Typical for global changes)"
			button btn_clearWorkedObjectsArray "Clear stored list of worked objects"
		)
		group "Execute"
		(
			radioButtons rBtn_level labels:levelList default:2
			button btn_setLevel "Execute set detail level"
		)
		
		--Buttons pressed:
		on btn_clearWorkedObjectsArray pressed do free workedObjectsArray
		on btn_setLevel pressed do
		(
			setWaitCursor()
			with redraw off
			(
				--Clear arrays that need to be cleared
				free allObjects
				free nonInstancesArray
				free duplicateObjectsArray
				
				--Sort objects:
				for obj = objects where \
				(if chkBox_includeSelected.checked == true or obj.isSelected == false then true else false) and \
				(if chkBox_includeNotSelected.checked == true or obj.isSelected == true then true else false) and \
				(if chkBox_includeHidden.checked == true or obj.isHidden == false then true else false) and \
				(if chkBox_includeVisible.checked == true or obj.isHidden == true then true else false) and \
				(if chkBox_includeFrozen.checked == true or obj.isFrozen == false then true else false) and \
				(if chkBox_includeNotFrozen.checked == true or obj.isFrozen == true then true else false) and \
				classOf obj == Body_Object \
				do append allObjects obj
				
				--Sort out instances of objects in the array:
				for obj = allObjects do
				(
					InstanceMgr.GetInstances obj &Instances
					if Instances.count == 1 then append nonInstancesArray obj else
					(
						if (findItem duplicateObjectsArray obj) == 0 do
						(
							append nonInstancesArray obj
							for i = Instances do append duplicateObjectsArray i
						)
					)
				)--END Sort out instances of objects in the array:
				
				
				--Create function to set detail level:
				fn fn_setDetailLevel obj level =
				(
					if level == "coarse" do
					(
						obj.LowQualityVDS = on
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = off
						obj.LowQualityVDS = on
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = off
						obj.IsoAngleDS = 15
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 30
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.IsoAngleDS = 15
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 30
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.IsoAngleDS = 15
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 30
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.LowQualityVDS = on
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = off
						obj.LowQualityVDS = on
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = off
						obj.LowQualityVDS = on
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = off
						obj.IsoAngleDS = 15
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 30
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.IsoAngleDS = 15
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 30
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.IsoAngleDS = 15
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 30
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.LowQualityVDS = on
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = off
						obj.LowQualityVDS = on
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = off
						obj.LowQualityVDS = on
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = off
						obj.IsoAngleDS = 15
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 30
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.IsoAngleDS = 15
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 30
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.IsoAngleDS = 15
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 30
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.LowQualityVDS = on
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = off
					)
					
					if level == "medium" do
					(
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = on
						obj.HighQualityVDS = off
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = on
						obj.HighQualityVDS = off
						obj.IsoAngleDS = 7
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 15
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.IsoAngleDS = 7
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 15
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = on
						obj.HighQualityVDS = off
						obj.IsoAngleDS = 7
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 15
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = on
						obj.HighQualityVDS = off
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = on
						obj.HighQualityVDS = off
						obj.IsoAngleDS = 7
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 15
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.IsoAngleDS = 7
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 15
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = on
						obj.HighQualityVDS = off
						obj.IsoAngleDS = 7
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 15
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.MediumQualityVDS = on
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = on
						obj.HighQualityVDS = off
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = on
						obj.HighQualityVDS = off
						obj.IsoAngleDS = 7
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 15
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.IsoAngleDS = 7
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 15
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = on
						obj.HighQualityVDS = off
						obj.IsoAngleDS = 7
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 15
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.1
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
					)
					
					if level == "fine" do
					(
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = on
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = on
						obj.IsoAngleDS = 3
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 10
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.02
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.IsoAngleDS = 3
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 10
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.02
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = on
						obj.IsoAngleDS = 3
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 10
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.02
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = on
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = on
						obj.IsoAngleDS = 3
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 10
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.02
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.IsoAngleDS = 3
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 10
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.02
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = on
						obj.IsoAngleDS = 3
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 10
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.02
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.HighQualityVDS = on
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = on
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = on
						obj.IsoAngleDS = 3
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 10
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.02
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.IsoAngleDS = 3
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 10
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.02
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
						obj.LowQualityVDS = off
						obj.MediumQualityVDS = off
						obj.HighQualityVDS = on
						obj.IsoAngleDS = 3
						obj.IsoChordHeightVDS = 0
						obj.FaceApproxAngleVDS = 10
						obj.EdgeApproxAngleVDS = 0
						obj.FaceChordHeightVDS = 0.02
						obj.EdgeChordHeightVDS = 0
						obj.MaxEdgeLengthPctVDS = 0
					)
				) --END function to set detail level
				
				
				--Do operations on objects
				local includeWorkedObjects = chkBox_includeWorkedObjects.checked
				local excludeFromWorkedObjects = chkBox_excludeFromWorkedObjects.checked
				local level = levelList[rBtn_level.state]
				
				undo "Set detail level" on
				(
					for obj in nonInstancesArray where includeWorkedObjects == true or (findItem workedObjectsArray obj) == 0 do
					(
						fn_setDetailLevel obj level
						if excludeFromWorkedObjects == false do appendIfUnique workedObjectsArray obj
					)--END operations on objects
				)--END Undo operation
				
			) --END with redraw off
		)--END btn_setLevel pressed
	)--END interface
	createDialog rollout_main 350 360
)