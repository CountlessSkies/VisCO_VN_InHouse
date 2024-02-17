try(destroydialog RL_SplineRig)catch()  
rollout RL_SplineRig "Spline Rig" width:230 height:185
(  
	label lbl_1 "Label" visible:false  
	spinner spn_numberOfKnots "Number Of Knots" type:#integer range:  [0,100,6]  
	spinner spn_knotControlSize "Knot Control Size" type:#float range:  [0,100,5]  
	spinner spn_tangentControlSize "Tangent Control Size" type:#float range:  [0,100,1]  
	checkbox chk_tangentControlBoxDisplay "Tangent Control Box Display" checked:false  
	spinner spn_segmentLength "Segment Length" type:#integer range:  [0,100,30]  
	label lbl_create "Create" visible:false  
	button btn_create "Create" width:150  

	on btn_create pressed do  
	(  
		numberOfKnots = spn_numberOfKnots.value 
		knotControlSize = spn_knotControlSize.value 
		tangentControlSize = spn_tangentControlSize.value 
		tangentControlBoxDisplay = chk_tangentControlBoxDisplay.checked 
		segmentLength = spn_segmentLength.value 

		the_tangent = attributes tangent  
		(  
			parameters main rollout:params  
			(  
				curvature type:  #float ui:curvature default:0  
				tangentA type:  #float ui:tangentA default:0  
				tangentB type:  #float ui:tangentB default:0  
			)  
			rollout params "Tangent Parameters"  
			(  
				spinner curvature "curvature"  
				spinner tangentA "tangentA" range:  [-100,100,0]  
				spinner tangentB "tangentB" range:  [-100,100,0]  
			)  
		) 

		generalControl = point name:"GeneralControl" size:(knotControlSize*2) box:true

		mySpline = SplineShape pos:  [0,0,0] wirecolor:(color 223 146 146) 

		addNewSpline mySpline 

		addModifier mySpline (skin()) 

		for i = 1 to numberOfKnots do 
		(  
			x = (i - 1)*segmentLength  
			tangentLength = segmentLength/3 
			
			if (i == 1) then  
			(  
				addKnot mySpline 1 #bezierCorner #curve [x,0,0] [x,0,0] [x + tangentLength,0,0]  
				myKnotControl = point name:("Ctrl_" + i as string) pos:  [x,0,0] box:true size:knotControlSize  
				myTangentControlB = point name:("Ctrl_" + i as string + "_tangentB") pos:  [x + tangentLength,0,0] box:tangentControlBoxDisplay size:tangentControlSize  
				myTangentControlB.parent = myKnotControl 
				myKnotControl.parent = generalControl 

				custAttributes.add myKnotControl the_tangent  
				myKnotControl.curvature = tangentLength 
				myKnotControl.curvature.controller = Bezier_Float()   
				myKnotControl.tangentB.controller = Bezier_Float()   

				exprCtrlTangentB = Float_Expression()   
				myTangentControlB.position.x_position.controller = exprCtrlTangentB  
				exprCtrlTangentB.AddScalarTarget "curvature" myKnotControl.curvature.controller  
				exprCtrlTangentB.AddScalarTarget "tangentB" myKnotControl.tangentB.controller  
				exprCtrlTangentB.SetExpression "curvature + tangentB"  

				skinOps.AddBone mySpline.skin myKnotControl 0  
				skinOps.AddBone mySpline.skin myTangentControlB 0  
				freeze myTangentControlB  
			)  
			else if ((i > 1) and (i < numberOfKnots)) then  
			(  
				addKnot mySpline 1 #bezierCorner #curve [x,0,0] [x - tangentLength,0,0] [x + tangentLength,0,0]  
				
				myKnotControl = point name:("Ctrl_" + i as string) pos:  [x,0,0] box:true size:knotControlSize  
				myTangentControlA = point name:("Ctrl_" + i as string + "_tangentA") pos:  [x - tangentLength,0,0] box:tangentControlBoxDisplay size:tangentControlSize  
				myTangentControlB = point name:("Ctrl_" + i as string + "_tangentB") pos:  [x + tangentLength,0,0] box:tangentControlBoxDisplay size:tangentControlSize  
				myTangentControlA.parent = myKnotControl  
				myTangentControlB.parent = myKnotControl 
				myKnotControl.parent = generalControl 

				custAttributes.add myKnotControl the_tangent  
				myKnotControl.curvature = tangentLength 
				myKnotControl.curvature.controller = Bezier_Float()   
				myKnotControl.tangentA.controller = Bezier_Float()   
				myKnotControl.tangentB.controller = Bezier_Float()   
				
				exprCtrlTangentA = Float_Expression()   
				myTangentControlA.position.x_position.controller = exprCtrlTangentA  
				exprCtrlTangentA.AddScalarTarget "curvature" myKnotControl.curvature.controller  
				exprCtrlTangentA.AddScalarTarget "tangentA" myKnotControl.tangentA.controller  
				exprCtrlTangentA.SetExpression "-(curvature + tangentA)"  

				exprCtrlTangentB = Float_Expression()   
				myTangentControlB.position.x_position.controller = exprCtrlTangentB  
				exprCtrlTangentB.AddScalarTarget "curvature" myKnotControl.curvature.controller  
				exprCtrlTangentB.AddScalarTarget "tangentB" myKnotControl.tangentB.controller  
				exprCtrlTangentB.SetExpression "curvature + tangentB"  

				skinOps.AddBone mySpline.skin myKnotControl 0  
				skinOps.AddBone mySpline.skin myTangentControlA 0  
				skinOps.AddBone mySpline.skin myTangentControlB 0  

				freeze myTangentControlA  
				freeze myTangentControlB  
			)  
			else  
			(  
				addKnot mySpline 1 #bezierCorner #curve [x,0,0] [x - 10,0,0] [x,0,0]  
				myKnotControl = point name:("Ctrl_" + i as string) pos:  [x,0,0] box:true size:knotControlSize  
				myTangentControlA = point name:("Ctrl_" + i as string + "_tangentA") pos:  [x - tangentLength,0,0] box:tangentControlBoxDisplay size:tangentControlSize  
				myTangentControlA.parent = myKnotControl  
				myKnotControl.parent = generalControl

				custAttributes.add myKnotControl the_tangent 
				myKnotControl.curvature = tangentLength  
				myKnotControl.curvature.controller = Bezier_Float()   
				myKnotControl.tangentA.controller = Bezier_Float()   

				exprCtrlTangentA = Float_Expression()   
				myTangentControlA.position.x_position.controller = exprCtrlTangentA  
				exprCtrlTangentA.AddScalarTarget "curvature" myKnotControl.curvature.controller  
				exprCtrlTangentA.AddScalarTarget "tangentA" myKnotControl.tangentA.controller  
				exprCtrlTangentA.SetExpression "-(curvature + tangentA)"  

				skinOps.AddBone mySpline.skin myKnotControl 0  
				skinOps.AddBone mySpline.skin myTangentControlA 0  

				freeze myTangentControlA  
			)  
		) 

		updateShape mySpline  

		select generalControl
	)
)

CreateDialog RL_SplineRig