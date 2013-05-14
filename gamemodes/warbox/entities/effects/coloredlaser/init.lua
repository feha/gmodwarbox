
function EFFECT:Init (fx)
	
	self.Material = Material("sprites/bluelaser1");
	self.Start = fx:GetStart();
	self.End = fx:GetOrigin();
	self.Width = fx:GetScale() or 1
	local Colour = fx:GetAngles() or Angle( 0, 0, 0 ) //I prefer Color, but that gets highlited
	self.R = Colour.p
	self.G = Colour.y
	self.B = Colour.r
	self.Time = 0;
	self.DTime = 0.3;
	
end

function EFFECT:Think ()
	self.Time = self.Time + FrameTime();
	return self.Time <= self.DTime;
end

function EFFECT:Render()
	render.SetMaterial(self.Material);
	render.DrawBeam (self.Start, self.End, self.Width, 0, 0, Color( self.R, self.G, self.B, 255 - (self.Time/self.DTime)*255) );
end