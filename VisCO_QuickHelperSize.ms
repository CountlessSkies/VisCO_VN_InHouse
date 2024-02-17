try(destroydialog RL_QuickHelperSize)catch()
rollout RL_QuickHelperSize "Quick Helper Size" width:150 height:70
(
	label lbl_1 "Label"  visible:false
	spinner spn_Size "Size"  type:#float range:[0,100,1]

	on spn_Size changed v do
	(
		for obj in selection where isKindOf obj Point do
		(
			obj.size = v
		)
	)
)

CreateDialog RL_QuickHelperSize