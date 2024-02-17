pointZero = point name:"Point_Zero" size:5 cross:true box:false wirecolor:(color 176 242 194)
pointLookAtNext = point name:"Point_LookAt_Next" size:5 cross:false box:true wirecolor:(color 176 242 194)
pointLookAtPrev = point name:"Point_LookAt_Prev" size:4 cross:false box:true wirecolor:(color 176 242 194)
pointOrientConstraint = point name:"Point_Orient_Constraint" size:1.5 cross:false box:true wirecolor:(color 176 242 194)
pointWireBone = point name:"Point_WireBone" size:0.5 cross:false box:true wirecolor:(color 176 242 194)

truckle = circle dir:[0,1,0] radius:2
truckle.radius.controller = Bezier_Float()
ResetTransform truckle

pointWireBoneXController = Float_Expression()
pointWireBone.position.z_position.controller = pointWireBoneXController
pointWireBoneXController.AddScalarTarget "R" truckle.radius.controller
pointWireBoneXController.SetExpression "R"