
function EFFECT:Init (fx)
	
	self.Material = Material("sprites/bluelaser1");
	self.Start = fx:GetStart();
	self.End = fx:GetOrigin();
	self.Width = fx:GetScale() or 1
	local color = fx:GetAngles() or Angle( 0, 0, 0 )
	self.R = color.p
	self.G = color.y
	self.B = color.r
	
	self.CurTime = 0
	self.EndTime = 0.3
	
end

function EFFECT:Think ()
	self.CurTime = self.CurTime + FrameTime()
	return self.CurTime <= self.EndTime
end

function EFFECT:Render()
	render.SetMaterial(self.Material)
	render.DrawBeam (self.Start, self.End, self.Width, 0, 0, Color( self.R, self.G, self.B, 255 - (self.CurTime/self.EndTime)*255) )
end