/*
This part of the script uses channelInfo (found in utilities panel) to transfer the UVW map channel from one object to another.
Saving and loading UVW mapping in the uvw modifier does not work automatically, since a manual save dialog box is forced, with no option to save via scripting

Link:
https://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__files_GUID_6D5BC18A_98C1_40AA_9617_DC1F20B4AFB2_htm
*/


(--START uvw_mapping
	
	struct UVW_Mapping
	(
		mapChannel,
		
		
		
		fn Get_UVW theObject =
		(
			channelInfo.CopyChannel theObject 3 mapChannel
		),
		
		
		
		fn Set_UVW theObject =
		(
			channelInfo.PasteChannel theObject 3 mapChannel
		)
		
		
	)
	
	
	
)--END uvw_mapping