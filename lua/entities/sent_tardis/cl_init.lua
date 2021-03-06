include('shared.lua')
 
--[[---------------------------------------------------------
   Name: Draw
   Purpose: Draw the model in-game.
   Remember, the things you render first will be underneath!
---------------------------------------------------------]]
function ENT:Draw() 
	if not self.phasing and self.visible then
		self:DrawModel()
		if WireLib then
			Wire_Render(self)
		end
	elseif self.phasing then
		if self.percent then
			if not self.phasemode and self.highPer <= 0 then
				self.phasing=false
			elseif self.phasemode and self.percent >= 1 then
				self.phasing=false
			end
		end
		
		self.percent = (self.phaselifetime - CurTime())
		self.highPer = self.percent + 0.5
		if self.phasemode then
			self.percent = (1-self.percent)-0.5
			self.highPer = self.percent+0.5
		end
		self.percent = math.Clamp( self.percent, 0, 1 )
		self.highPer = math.Clamp( self.highPer, 0, 1 )

		--Drawing original model
		local normal = self:GetUp()
		local origin = self:GetPos() + self:GetUp() * (self.maxs.z - ( self.height * self.highPer ))
		local distance = normal:Dot( origin )
		
		render.EnableClipping( true )
		render.PushCustomClipPlane( normal, distance )
			self:DrawModel()
		render.PopCustomClipPlane()
		
		local restoreT = self:GetMaterial()
		
		--Drawing phase texture
		render.MaterialOverride( self.wiremat )

		normal = self:GetUp()
		distance = normal:Dot( origin )
		render.PushCustomClipPlane( normal, distance )
		
		local normal2 = self:GetUp() * -1
		local origin2 = self:GetPos() + self:GetUp() * (self.maxs.z - ( self.height * self.percent ))
		local distance2 = normal2:Dot( origin2 )
		render.PushCustomClipPlane( normal2, distance2 )
			self:DrawModel()
		render.PopCustomClipPlane()
		render.PopCustomClipPlane()
		
		render.MaterialOverride( restoreT )
		render.EnableClipping( false )
	end
end

function ENT:Phase(mode)
	self.phasing=true
	self.phaseactive=true
	self.phaselifetime=CurTime()+1
	self.phasemode=not mode // it likes to reverse
end

function ENT:Initialize()
	self.health=100
	self.phasemode=false
	self.visible=true
	self.flightmode=false
	self.visible=true
	self.power=true
	self.z=0
	self.phasedraw=0
	self.mins = self:OBBMins()
	self.maxs = self:OBBMaxs()
	self.wiremat = Material( "models/drmatt/tardis/phase" )
	self.height = self.maxs.z - self.mins.z
end

function ENT:OnRemove()
	if self.flightloop then
		self.flightloop:Stop()
		self.flightloop=nil
	end
	if self.flightloop2 then
		self.flightloop2:Stop()
		self.flightloop2=nil
	end
end

function ENT:Think()
	if tobool(GetConVarNumber("tardis_flightsound"))==true then
		if not self.flightloop then
			self.flightloop=CreateSound(self, "tardis/flight_loop.wav")
			self.flightloop:SetSoundLevel(90)
			self.flightloop:Stop()
		end
		if self.flightmode and self.visible and not self.moving then
			if !self.flightloop:IsPlaying() then
				self.flightloop:Play()
			end
			local e = LocalPlayer():GetViewEntity()
			if !IsValid(e) then e = LocalPlayer() end
			local tardis=LocalPlayer().tardis
			if not (tardis and IsValid(tardis) and tardis==self and e==LocalPlayer()) then
				local pos = e:GetPos()
				local spos = self:GetPos()
				local doppler = (pos:Distance(spos+e:GetVelocity())-pos:Distance(spos+self:GetVelocity()))/200
				if self.exploded then
					local r=math.random(90,130)
					self.flightloop:ChangePitch(math.Clamp(r+doppler,80,120),0.1)
				else
					self.flightloop:ChangePitch(math.Clamp((self:GetVelocity():Length()/250)+95+doppler,80,120),0.1)
				end
				self.flightloop:ChangeVolume(GetConVarNumber("tardis_flightvol"),0)
			else
				if self.exploded then
					local r=math.random(90,130)
					self.flightloop:ChangePitch(r,0.1)
				else
					local p=math.Clamp(self:GetVelocity():Length()/250,0,15)
					self.flightloop:ChangePitch(95+p,0.1)
				end
				self.flightloop:ChangeVolume(0.75*GetConVarNumber("tardis_flightvol"),0)
			end
		else
			if self.flightloop:IsPlaying() then
				self.flightloop:Stop()
			end
		end
		
		local interior=self:GetNWEntity("interior",NULL)
		if not self.flightloop2 and interior and IsValid(interior) then
			self.flightloop2=CreateSound(interior, "tardis/flight_loop.wav")
			self.flightloop2:Stop()
		end
		if self.flightloop2 and (self.flightmode or self.invortex) and LocalPlayer().tardis_viewmode and not IsValid(LocalPlayer().tardis_skycamera) and interior and IsValid(interior) and ((self.invortex and self.moving) or not self.moving) then
			if !self.flightloop2:IsPlaying() then
				self.flightloop2:Play()
				self.flightloop2:ChangeVolume(0.4,0)
			end
			if self.exploded then
				local r=math.random(90,130)
				self.flightloop2:ChangePitch(r,0.1)
			else
				local p=math.Clamp(self:GetVelocity():Length()/250,0,15)
				self.flightloop2:ChangePitch(95+p,0.1)
			end
		elseif self.flightloop2 then
			if self.flightloop2:IsPlaying() then
				self.flightloop2:Stop()
			end
		end
	else
		if self.flightloop then
			self.flightloop:Stop()
			self.flightloop=nil
		end
		if self.flightloop2 then
			self.flightloop2:Stop()
			self.flightloop2=nil
		end
	end
	
	if self.light_on and tobool(GetConVarNumber("tardis_dynamiclight"))==true then
		local dlight = DynamicLight( self:EntIndex() )
		if ( dlight ) then
			local size=400
			local c=Color(255,255,255)
			dlight.Pos = self:GetPos() + self:GetUp() * 130
			dlight.r = c.r
			dlight.g = c.g
			dlight.b = c.b
			dlight.Brightness = 5
			dlight.Decay = size * 5
			dlight.Size = size
			dlight.DieTime = CurTime() + 1
		end
	end
end

net.Receive("TARDIS-UpdateVis", function()
	local ent=net.ReadEntity()
	ent.visible=tobool(net.ReadBit())
end)

net.Receive("TARDIS-Phase", function()
	local ent=net.ReadEntity()
	ent.visible=tobool(net.ReadBit())
	ent:Phase(not ent.visible) // it likes to reverse
end)

net.Receive("TARDIS-Explode", function()
	local ent=net.ReadEntity()
	ent.exploded=true
end)

net.Receive("TARDIS-UnExplode", function()
	local ent=net.ReadEntity()
	ent.exploded=false
end)

net.Receive("TARDIS-Flightmode", function()
	local ent=net.ReadEntity()
	ent.flightmode=tobool(net.ReadBit())
end)

net.Receive("TARDIS-SetInterior", function()
	local ent=net.ReadEntity()
	ent.interior=net.ReadEntity()
end)

net.Receive("TARDIS-Go", function()
	local tardis=net.ReadEntity()
	if IsValid(tardis) then
		tardis.moving=true
	end
	local interior=net.ReadEntity()
	local exploded=tobool(net.ReadBit())
	local pitch=(exploded and 110 or 100)
	local long=tobool(net.ReadBit())
	local quickdemat=tobool(net.ReadBit())
	if tobool(GetConVarNumber("tardis_matsound"))==true then
		if IsValid(tardis) and LocalPlayer().tardis==tardis then
			if tardis.visible then
				if long then
					if quickdemat then
						tardis:EmitSound("tardis/quickdemat.wav", 100, pitch)
					else
						tardis:EmitSound("tardis/demat.wav", 100, pitch)
					end
				else
					tardis:EmitSound("tardis/full.wav", 100, pitch)
				end
			end
			if interior and IsValid(interior) and LocalPlayer().tardis_viewmode and not IsValid(LocalPlayer().tardis_skycamera) then
				if long then
					if quickdemat then
						interior:EmitSound("tardis/quickdemat.wav", 100, pitch)
					else
						interior:EmitSound("tardis/demat.wav", 100, pitch)
					end
				else
					interior:EmitSound("tardis/full.wav", 100, pitch)
				end
			end
		elseif IsValid(tardis) and tardis.visible then
			local pos=net.ReadVector()
			local pos2=net.ReadVector()
			if pos then
				if quickdemat then
					sound.Play("tardis/quickdemat.wav", pos, 75, pitch)
				else
					sound.Play("tardis/demat.wav", pos, 75, pitch)
				end
			end
			if pos2 and not long then
				sound.Play("tardis/mat.wav", pos2, 75, pitch)
			end
		end
	end
end)

net.Receive("TARDIS-Stop", function()
	tardis=net.ReadEntity()
	if IsValid(tardis) then
		tardis.moving=nil
	end
end)

net.Receive("TARDIS-Reappear", function()
	local tardis=net.ReadEntity()
	local interior=net.ReadEntity()
	local exploded=tobool(net.ReadBit())
	local pitch=(exploded and 110 or 100)
	if tobool(GetConVarNumber("tardis_matsound"))==true then
		if IsValid(tardis) and LocalPlayer().tardis==tardis then
			if tardis.visible then
				tardis:EmitSound("tardis/mat.wav", 100, pitch)
			end
			if interior and IsValid(interior) and LocalPlayer().tardis_viewmode and not IsValid(LocalPlayer().tardis_skycamera) then
				interior:EmitSound("tardis/mat.wav", 100, pitch)
			end
		elseif IsValid(tardis) and tardis.visible then
			sound.Play("tardis/mat.wav", net.ReadVector(), 75, pitch)
		end
	end
end)

net.Receive("Player-SetTARDIS", function()
	local ply=net.ReadEntity()
	ply.tardis=net.ReadEntity()
end)

net.Receive("TARDIS-SetHealth", function()
	local tardis=net.ReadEntity()
	tardis.health=net.ReadFloat()
end)

net.Receive("TARDIS-SetLocked", function()
	local tardis=net.ReadEntity()
	local interior=net.ReadEntity()
	local locked=tobool(net.ReadBit())
	local makesound=tobool(net.ReadBit())
	if IsValid(tardis) then
		tardis.locked=locked
		if tobool(GetConVarNumber("tardis_locksound"))==true and makesound then
			sound.Play("tardis/lock.wav", tardis:GetPos())
		end
	end
	if IsValid(interior) then
		if tobool(GetConVarNumber("tardis_locksound"))==true and not IsValid(LocalPlayer().tardis_skycamera) and makesound then
			sound.Play("tardis/lock.wav", interior:LocalToWorld(Vector(300,295,-79)))
		end
	end
end)

net.Receive("TARDIS-SetViewmode", function()
	LocalPlayer().tardis_viewmode=tobool(net.ReadBit())
	LocalPlayer().ShouldDisableLegs=(not LocalPlayer().tardis_viewmode)
	
	if LocalPlayer().tardis_viewmode and GetConVarNumber("r_rootlod")>0 then
		Derma_Query("The TARDIS Interior requires model detail on high, set now?", "TARDIS Interior", "Yes", function() RunConsoleCommand("r_rootlod", 0) end, "No", function() end)
	end
		
end)

hook.Add( "ShouldDrawLocalPlayer", "TARDIS-ShouldDrawLocalPlayer", function(ply)
	if IsValid(ply.tardis) and not ply.tardis_viewmode then
		return false
	end
end)

net.Receive("TARDIS-PlayerEnter", function()
	if tobool(GetConVarNumber("tardis_doorsound"))==true then
		local ent1=net.ReadEntity()
		local ent2=net.ReadEntity()
		if IsValid(ent1) and ent1.visible then
			sound.Play("tardis/door.wav", ent1:GetPos())
		end
		if IsValid(ent2) and not IsValid(LocalPlayer().tardis_skycamera) then
			sound.Play("tardis/door.wav", ent2:LocalToWorld(Vector(300,295,-79)))
		end
	end
end)

net.Receive("TARDIS-PlayerExit", function()
	if tobool(GetConVarNumber("tardis_doorsound"))==true then
		local ent1=net.ReadEntity()
		local ent2=net.ReadEntity()
		if IsValid(ent1) and ent1.visible then
			sound.Play("tardis/door2.wav", ent1:GetPos())
		end
		if IsValid(ent2) and not IsValid(LocalPlayer().tardis_skycamera) then
			sound.Play("tardis/door2.wav", ent2:LocalToWorld(Vector(300,295,-79)))
		end
	end
end)

net.Receive("TARDIS-SetRepairing", function()
	local tardis=net.ReadEntity()
	local repairing=tobool(net.ReadBit())
	local interior=net.ReadEntity()
	if IsValid(tardis) then
		tardis.repairing=repairing
	end
	if IsValid(interior) and LocalPlayer().tardis==tardis and LocalPlayer().tardis_viewmode and tobool(GetConVarNumber("tardisint_powersound"))==true then
		if repairing then
			sound.Play("tardis/powerdown.wav", interior:GetPos())
		else
			sound.Play("tardis/powerup.wav", interior:GetPos())
		end
	end
end)

net.Receive("TARDIS-BeginRepair", function()
	local tardis=net.ReadEntity()
	if IsValid(tardis) then
		/*
		local mat=Material("models/drmatt/tardis/tardis_df")
		if not mat:IsError() then
			mat:SetTexture("$basetexture", "models/props_combine/metal_combinebridge001")
		end
		*/
	end
end)

net.Receive("TARDIS-FinishRepair", function()
	local tardis=net.ReadEntity()
	if IsValid(tardis) then
		if tobool(GetConVarNumber("tardisint_repairsound"))==true and tardis.visible then
			sound.Play("tardis/repairfinish.wav", tardis:GetPos())
		end
		/*
		local mat=Material("models/drmatt/tardis/tardis_df")
		if not mat:IsError() then
			mat:SetTexture("$basetexture", "models/drmatt/tardis/tardis_df")
		end
		*/
	end
end)

net.Receive("TARDIS-SetLight", function()
	local tardis=net.ReadEntity()
	local on=tobool(net.ReadBit())
	if IsValid(tardis) then
		tardis.light_on=on
	end
end)

net.Receive("TARDIS-SetPower", function()
	local tardis=net.ReadEntity()
	local on=tobool(net.ReadBit())
	local interior=net.ReadEntity()
	if IsValid(tardis) then
		tardis.power=on
	end
	if IsValid(interior) and LocalPlayer().tardis==tardis and LocalPlayer().tardis_viewmode and tobool(GetConVarNumber("tardisint_powersound"))==true then
		if on then
			sound.Play("tardis/powerup.wav", interior:GetPos())
		else
			sound.Play("tardis/powerdown.wav", interior:GetPos())
		end
	end
end)

net.Receive("TARDIS-SetVortex", function()
	local tardis=net.ReadEntity()
	local on=tobool(net.ReadBit())
	if IsValid(tardis) then
		tardis.invortex=on
	end
end)

surface.CreateFont( "HUDNumber", {font="Trebuchet MS", size=40, weight=900} )

hook.Add("HUDPaint", "TARDIS-DrawHUD", function()
	local p = LocalPlayer()
	local tardis = p.tardis
	if tardis and IsValid(tardis) and tardis.health and (tobool(GetConVarNumber("tardis_takedamage"))==true or tardis.exploded) then
		local health = math.floor(tardis.health)
		local n=0
		if health <= 99 then
			n=20
		end
		if health <= 9 then
			n=40
		end
		local col=Color(255,255,255)
		if health <= 20 then
			col=Color(255,0,0)
		end
		draw.RoundedBox( 0, 5, ScrH()-55, 220-n, 50, Color(0, 0, 0, 180) )
		draw.DrawText("Health: "..health.."%","HUDNumber", 15, ScrH()-52, col)
	end
end)

hook.Add("CalcView", "TARDIS_CLView", function( ply, origin, angles, fov )
	local tardis=LocalPlayer().tardis
	local viewent = LocalPlayer():GetViewEntity()
	if !IsValid(viewent) then viewent = LocalPlayer() end
	local dist= -300
	
	if tardis and IsValid(tardis) and viewent==LocalPlayer() and not LocalPlayer().tardis_viewmode then
		local pos=tardis:GetPos()+(tardis:GetUp()*50)
		local tracedata={}
		tracedata.start=pos
		tracedata.endpos=pos+ply:GetAimVector():GetNormal()*dist
		tracedata.mask=MASK_NPCWORLDSTATIC
		local trace=util.TraceLine(tracedata)
		local view = {}
		view.origin = trace.HitPos
		view.angles = angles
		return view
	end
end)

local checkbox_options={
	{"Flight sounds", "tardis_flightsound", false},
	{"Teleport sounds", "tardis_matsound", false},
	{"Door sounds", "tardis_doorsound", false},
	{"Lock sounds", "tardis_locksound", false},
	{"Repair sounds", "tardisint_repairsound", false},
	{"Power sounds", "tardisint_powersound", false},
	{"Cloisterbell sound", "tardisint_cloisterbell", false},
	{"Flightmode music", "tardisint_musicext", false},
	{"Interior rails", "tardisint_rails", true},
	{"Interior idle sounds", "tardisint_idlesound", false},
	{"Interior control sounds", "tardisint_controlsound", false},
	{"Interior music", "tardisint_music", false},
	{"Interior scanner", "tardisint_scanner", false},
	{"Interior dynamic light", "tardisint_dynamiclight", false},
	{"Exterior dynamic light", "tardis_dynamiclight", false},
	{"Control tool tips", "tardisint_tooltip", false},
	{"Control halos", "tardisint_halos", false},
}

for k,v in pairs(checkbox_options) do
	CreateClientConVar(v[2], "1", true, v[3])
end

CreateClientConVar("tardisint_mainlight_r", "255", true)
CreateClientConVar("tardisint_mainlight_g", "50", true)
CreateClientConVar("tardisint_mainlight_b", "0", true)

CreateClientConVar("tardisint_seclight_r", "0", true)
CreateClientConVar("tardisint_seclight_g", "255", true)
CreateClientConVar("tardisint_seclight_b", "0", true)

CreateClientConVar("tardisint_warnlight_r", "200", true)
CreateClientConVar("tardisint_warnlight_g", "0", true)
CreateClientConVar("tardisint_warnlight_b", "0", true)

CreateClientConVar("tardisint_musicvol", "1", true)
CreateClientConVar("tardis_flightvol", "1", true)

CreateClientConVar("tardis_globalskin", "0", true, true)

hook.Add("PopulateToolMenu", "TARDIS-PopulateToolMenu", function()
	spawnmenu.AddToolMenuOption("Options", "Doctor Who", "TARDIS_Options", "TARDIS", "", "", function(panel)
		panel:ClearControls()
		//Do menu things here
		
		local button = vgui.Create("DButton")
		button:SetText("Advanced Mode Help")
		button.DoClick = function(self)
			local window = vgui.Create( "DFrame" )
			window:SetSize( 415,220 )
			window:Center()
			window:SetTitle( "TARDIS Advanced Mode Help" )
			window:MakePopup()

			local DLabel = vgui.Create( "DLabel", window )
			DLabel:SetPos(7.5,30)
			DLabel:SetText(
				[[
				The TARDIS advanced flight mode requires the player to press a series of controls
				around the console area in order to successfully dematerialise.
				
				This build of the mod requires the following combination of controls (in order):
				
				1. Activate the flightmode (Navigations/Programmable/Vortex)
				2. Dial the Helmic Regulator
				3. Apply the Locking Down Mechanism
				4. Release the Time-Rotor Handbrake
				5. Alternate the Space-Time Throttle
				
				Sounds will indicate if you have pressed the correct control or the wrong control.
				
				Happy dematerialising!
				]]
			)
			DLabel:SizeToContents()
		end
		panel:AddItem(button)
		
		local checkBox = vgui.Create( "DCheckBoxLabel" )
		checkBox:SetText( "Double spawn trace (Admin Only)" )
		checkBox:SetToolTip( "This should fix some maps where the interior/skycamera doesn't spawn properly" )
		checkBox:SetValue( GetConVarNumber( "tardis_doubletrace" ) )
		checkBox:SetDisabled(not (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()))
		checkBox.OnChange = function(self,val)
			if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
				net.Start("TARDIS-DoubleTrace")
					net.WriteFloat(val==true and 1 or 0)
				net.SendToServer()
			else
				chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to change this option.")
				chat.PlaySound()
			end
		end
		panel:AddItem(checkBox)
		
		local checkBox = vgui.Create( "DCheckBoxLabel" )
		checkBox:SetText( "Take damage (Admin Only)" )
		checkBox:SetValue( GetConVarNumber( "tardis_takedamage" ) )
		checkBox:SetDisabled(not (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()))
		checkBox.OnChange = function(self,val)
			if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
				net.Start("TARDIS-TakeDamage")
					net.WriteFloat(val==true and 1 or 0)
				net.SendToServer()
			else
				chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to change this option.")
				chat.PlaySound()
			end			
		end
		panel:AddItem(checkBox)
		
		local checkBox = vgui.Create( "DCheckBoxLabel" )
		checkBox:SetText( "Allow phasing in flightmode (Admin Only)" )
		checkBox:SetValue( GetConVarNumber( "tardis_flightphase" ) )
		checkBox:SetDisabled(not (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()))
		checkBox.OnChange = function(self,val)
			if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
				net.Start("TARDIS-FlightPhase")
					net.WriteFloat(val==true and 1 or 0)
				net.SendToServer()
			else
				chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to change this option.")
				chat.PlaySound()
			end
		end
		panel:AddItem(checkBox)
		
		local checkBox = vgui.Create( "DCheckBoxLabel" )
		checkBox:SetText( "Physical Damage (Admin Only)" )
		checkBox:SetToolTip( "This enables/disables physical damage from hitting stuff at high speeds." )
		checkBox:SetValue( GetConVarNumber( "tardis_physdamage" ) )
		checkBox:SetDisabled(not (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()))
		checkBox.OnChange = function(self,val)
			if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
				net.Start("TARDIS-PhysDamage")
					net.WriteFloat(val==true and 1 or 0)
				net.SendToServer()
			else
				chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to change this option.")
				chat.PlaySound()
			end
		end
		panel:AddItem(checkBox)
		
		local checkBox = vgui.Create( "DCheckBoxLabel" )
		checkBox:SetText( "No-collide during teleport (Admin Only)" )
		checkBox:SetToolTip( "This enables no-collide on the TARDIS when it is teleporting and disables it after again." )
		checkBox:SetValue( GetConVarNumber( "tardis_nocollideteleport" ) )
		checkBox:SetDisabled(not (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()))
		checkBox.OnChange = function(self,val)
			if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
				net.Start("TARDIS-NoCollideTeleport")
					net.WriteFloat(val==true and 1 or 0)
				net.SendToServer()
			else
				chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to change this option.")
				chat.PlaySound()
			end
		end
		panel:AddItem(checkBox)
		
		local checkBox = vgui.Create( "DCheckBoxLabel" )
		checkBox:SetText( "Advanced Mode (Admin Only)" )
		checkBox:SetToolTip( "This sets interior navigation to advanced, turn off for easy." )
		checkBox:SetValue( GetConVarNumber( "tardis_advanced" ) )
		checkBox:SetDisabled(not (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()))
		checkBox.OnChange = function(self,val)
			if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
				net.Start("TARDIS-AdvancedMode")
					net.WriteFloat(val==true and 1 or 0)
				net.SendToServer()
			else
				chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to change this option.")
				chat.PlaySound()
			end
		end
		panel:AddItem(checkBox)
		
		local checkBox = vgui.Create( "DCheckBoxLabel" )
		checkBox:SetText( "Lock doors during teleport (Admin Only)" )
		checkBox:SetToolTip( "This stops players from entering/leaving while it is teleporting." )
		checkBox:SetValue( GetConVarNumber( "tardis_teleportlock" ) )
		checkBox:SetDisabled(not (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin()))
		checkBox.OnChange = function(self,val)
			if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
				net.Start("TARDIS-TeleportLock")
					net.WriteFloat(val==true and 1 or 0)
				net.SendToServer()
			else
				chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to change this option.")
				chat.PlaySound()
			end
		end
		panel:AddItem(checkBox)
		
		/* -- i feel people arnt going to know what this does and end up breaking everything, the above checkbox should help in most cases.
		local slider = vgui.Create( "DNumSlider" )
			slider:SetText( "Spawn Offset (Admin Only)" )
			slider:SetToolTip("Try the above checkbox first, this is a last resort for advanced users only.")
			slider:SetValue(0)
			slider:SetDecimals(0)
			slider:SetMin(-10000)
			slider:SetMax(5000)
			slider.val=0
			slider.OnValueChanged = function(self,val)
				if not (slider.val==val) then
					slider.val=val
					if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
						net.Start("TARDIS-SpawnOffset")
							net.WriteFloat(val)
						net.SendToServer()
					else
						chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to change this option.")
						chat.PlaySound()
					end
				end
			end
			panel:AddItem(slider)
			
		local button = vgui.Create( "DButton" )
		button:SetText( "Reset Spawn Offset" )
		button.DoClick = function(self)
			if LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() then
				if slider then
					slider:SetValue(0)
				end
			else
				chat.AddText(Color(255,62,62), "WARNING: ", Color(255,255,255), "You must be an admin to use this button.")
				chat.PlaySound()
			end
		end
		panel:AddItem(button)
		*/
		
		local DLabel = vgui.Create( "DLabel" )
		DLabel:SetText("Interior Lighting:")
		panel:AddItem(DLabel)
		
		local CategoryList = vgui.Create( "DPanelList" )
		//CategoryList:SetAutoSize( true )
		CategoryList:SetTall( 260 )
		CategoryList:SetSpacing( 10 )
		CategoryList:EnableHorizontal( false )
		CategoryList:EnableVerticalScrollbar( true )
		
		local DLabel = vgui.Create( "DLabel" )
		DLabel:SetText("Main Color:")
		CategoryList:AddItem(DLabel)
		
		local Mixer1 = vgui.Create( "DColorMixer" )
		Mixer1:SetPalette( true )  		--Show/hide the palette			DEF:true
		Mixer1:SetAlphaBar( false ) 		--Show/hide the alpha bar		DEF:true
		Mixer1:SetWangs( true )	 		--Show/hide the R G B A indicators 	DEF:true
		Mixer1:SetColor( Color(GetConVarNumber("tardisint_mainlight_r"), GetConVarNumber("tardisint_mainlight_g"), GetConVarNumber("tardisint_mainlight_b")) )	--Set the default color
		Mixer1.ValueChanged = function(self,col)
			RunConsoleCommand("tardisint_mainlight_r", col.r)
			RunConsoleCommand("tardisint_mainlight_g", col.g)
			RunConsoleCommand("tardisint_mainlight_b", col.b)
		end
		CategoryList:AddItem(Mixer1)
		
		local DLabel = vgui.Create( "DLabel" )
		DLabel:SetText("Secondary Color:")
		CategoryList:AddItem(DLabel)
		
		local Mixer2 = vgui.Create( "DColorMixer" )
		Mixer2:SetPalette( true )  		--Show/hide the palette			DEF:true
		Mixer2:SetAlphaBar( false ) 		--Show/hide the alpha bar		DEF:true
		Mixer2:SetWangs( true )	 		--Show/hide the R G B A indicators 	DEF:true
		Mixer2:SetColor( Color(GetConVarNumber("tardisint_seclight_r"), GetConVarNumber("tardisint_seclight_g"), GetConVarNumber("tardisint_seclight_b")) )	--Set the default color
		Mixer2.ValueChanged = function(self,col)
			RunConsoleCommand("tardisint_seclight_r", col.r)
			RunConsoleCommand("tardisint_seclight_g", col.g)
			RunConsoleCommand("tardisint_seclight_b", col.b)
		end
		CategoryList:AddItem(Mixer2)
		
		local DLabel = vgui.Create( "DLabel" )
		DLabel:SetText("Warning Color:")
		CategoryList:AddItem(DLabel)
		
		local Mixer3 = vgui.Create( "DColorMixer" )
		Mixer3:SetPalette( true )  		--Show/hide the palette			DEF:true
		Mixer3:SetAlphaBar( false ) 		--Show/hide the alpha bar		DEF:true
		Mixer3:SetWangs( true )	 		--Show/hide the R G B A indicators 	DEF:true
		Mixer3:SetColor( Color(GetConVarNumber("tardisint_warnlight_r"), GetConVarNumber("tardisint_warnlight_g"), GetConVarNumber("tardisint_warnlight_b")) )	--Set the default color
		Mixer3.ValueChanged = function(self,col)
			RunConsoleCommand("tardisint_warnlight_r", col.r)
			RunConsoleCommand("tardisint_warnlight_g", col.g)
			RunConsoleCommand("tardisint_warnlight_b", col.b)
		end
		CategoryList:AddItem(Mixer3)
		
		panel:AddItem(CategoryList)
		
		local button = vgui.Create("DButton")
		button:SetText("Reset Colors")
		button.DoClick = function(self)
			Mixer1:SetColor(Color(255,50,0))
			Mixer2:SetColor(Color(0,255,0))
			Mixer3:SetColor(Color(200,0,0))
		end
		panel:AddItem(button)
		
		panel:AddControl("Slider", {
			Label="Music Volume",
			Type="float",
			Min=0.1,
			Max=1,
			Command="tardisint_musicvol",
		})
		
		panel:AddControl("Slider", {
			Label="Exterior Flight Volume",
			Type="float",
			Min=0.1,
			Max=1,
			Command="tardis_flightvol",
		})
		
		
		local skins={
			{"2005 Skin", 1},
			{"Old 2010 Skin", 2},
			{"2010 Skin", 0},
		}
		local comboBox = vgui.Create("DComboBox")
		comboBox:SetText("Global Skin")
		for k,v in ipairs(skins) do
			comboBox:AddChoice(v[1])
		end
		for k,v in pairs(skins) do
			if GetConVarNumber("tardis_globalskin")==v[2] then
				comboBox:ChooseOption(v[1])
			end
		end
		comboBox.OnSelect = function(panel,index,value,data)
			local n=0
			for k,v in pairs(skins) do
				if value==v[1] then
					n=v[2]
				end
			end
			RunConsoleCommand("tardis_globalskin", n)
		end
		panel:AddItem(comboBox)
		
		local checkboxes={}
		for k,v in pairs(checkbox_options) do
			local checkBox = vgui.Create( "DCheckBoxLabel" ) 
			checkBox:SetText( v[1] ) 
			checkBox:SetValue( GetConVarNumber( v[2] ) )
			checkBox:SetConVar( v[2] )
			panel:AddItem(checkBox)
			table.insert(checkboxes, checkBox)
		end
	end)
end)

hook.Add( "HUDShouldDraw", "TARDIS-HideHUD", function(name)
	local viewmode=LocalPlayer().tardis_viewmode
	if ((name == "CHudHealth") or (name == "CHudBattery")) and viewmode then
		return false
	end
end)