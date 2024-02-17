try(destroydialog RL_QuickFade)catch()  
rollout RL_QuickFade "QuickFade" width:250 height:150
(  
	label lbl_1 "Label" visible:false  
	spinner spn_Duration "Duration" type:#integer range:  [0,100,15]  
	checkbox chk_JumpToLastFrame "Jump To Last Frame" checked:true  
	button btn_FadeIn "Fade In" across:2 width:112.5 usePercentageWidth:true percentageWidth:45.0 align:#left  
	button btn_FadeOut "Fade Out" width:112.5 usePercentageWidth:true percentageWidth:45.0  
	label lbl_2 "Label" visible:false  
	button btn_DeleteAllKeyFrames "Delete All Keyframes" width:150 enabled:true  

	On btn_FadeOut pressed do
	( 
		for obj in selection where superClassOf obj != helper do 
		(
            obj.visibility = NewDefaultFloatController()
			(addNewKey obj.visibility.controller currentTime).value = 1
			(addNewKey obj.visibility.controller (currentTime + spn_Duration.value)).value = 0
			-- (addNewKey obj.visibility.controller animationRange.start).value = 1
		)
        if chk_JumpToLastFrame.checked == true do sliderTime = currentTime + spn_Duration.value
	)

    On btn_FadeIn pressed do
	(
		for obj in selection where superClassOf obj == GeometryClass do 
		(
            obj.visibility = NewDefaultFloatController()
			(addNewKey obj.visibility.controller currentTime).value = 1
			(addNewKey obj.visibility.controller (currentTime - spn_Duration.value)).value = 0
			-- (addNewKey obj.visibility.controller animationRange.start).value = 0
		)
        if chk_JumpToLastFrame.checked == true do sliderTime = currentTime - spn_Duration.value
	)

    On btn_DeleteAllKeyFrames pressed do
    (
        for obj in selection where superClassOf obj == GeometryClass do
        (
            if numKeys obj.visibility.controller != 0 do
            (
                deleteKeys obj.visibility.controller #allKeys
                obj.visibility = 1
            )
        )
    )
)

CreateDialog RL_QuickFade