/******************************************************************************\
	TARDIS custom E2 functions by Dr. Matt
\******************************************************************************/

E2Lib.RegisterExtension("tardis", true)

local function TARDIS_Get(ent)
	if ent and IsValid(ent) then
		if ent:GetClass()=="sent_tardis_interior" and IsValid(ent.tardis) then
			return ent.tardis
		elseif ent:GetClass()=="sent_tardis" then
			return ent
		elseif ent:IsPlayer() then
			if IsValid(ent.tardis) then
				return ent.tardis
			else
				return NULL
			end
		else
			return NULL
		end
	end
	return NULL
end

local function TARDIS_Teleport(ent,pos,ang)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		local pos=Vector(pos[1], pos[2], pos[3])
		if ang then ang=Angle(ang[1], ang[2], ang[3]) end
		local success=ent:Go(pos,ang)
		if success then
			return 1
		else
			return 0
		end
	else
		return 0
	end
end

local function TARDIS_Phase(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		local success=ent:TogglePhase()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Flightmode(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		local success=ent:ToggleFlight()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Lock(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		local success=ent:ToggleLocked()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Physlock(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		local success=ent:TogglePhysLock()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Power(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		local success=ent:TogglePower()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Isomorph(data,ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") or not IsValid(data.player) then return 0 end
		local success=ent:IsomorphicToggle(data.player)
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Longflight(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		local success=ent:ToggleLongFlight()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Materialise(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		local success=ent:LongReappear()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Selfrepair(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		local success=ent:ToggleRepair()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Track(ent,trackent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		local success=ent:SetTrackingEnt(trackent)
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Spinmode(ent,spinmode)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		ent:SetSpinMode(spinmode)
		return ent.spinmode
	end
	return 0
end

local function TARDIS_SetDestination(ent,pos,ang)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		local pos=Vector(pos[1], pos[2], pos[3])
		if ang then ang=Angle(ang[1], ang[2], ang[3]) end
		if ent.invortex then
			ent:SetDestination(pos,ang)
			return 1
		else
			return 0
		end
	else
		return 0
	end
end

local function TARDIS_HADS(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		local success=ent:ToggleHADS()
		if success then
			return 1
		else
			return 0
		end
	end
	return 0
end

// get details

local function TARDIS_Moving(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		if ent.moving then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Visible(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		if ent.visible then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Flying(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		if ent.flightmode then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Locked(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		if ent.locked then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Physlocked(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		if ent.physlocked then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Powered(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		if ent.power then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Isomorphic(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		if ent.isomorphic then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Longflighted(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		if ent.longflight then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Selfrepairing(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		if ent.repairing then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_LastPos(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		if ent.lastpos then
			return ent.lastpos
		else
			return Vector()
		end
	end
	return Vector()
end

local function TARDIS_LastAng(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		if ent.lastang then
			return {ent.lastang.p, ent.lastang.y, ent.lastang.r}
		else
			return {0,0,0}
		end
	end
	return {0,0,0}
end

local function TARDIS_Health(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		if ent.health then
			return math.floor(ent.health)
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_Tracking(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		if IsValid(ent.trackingent) then
			return ent.trackingent
		else
			return NULL
		end
	end
	return NULL
end

local function TARDIS_InVortex(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		if ent.invortex then
			return 1
		else
			return 0
		end
	end
	return 0
end

local function TARDIS_IsHADS(ent)
	if ent and IsValid(ent) then
		if not (ent:GetClass()=="sent_tardis") then return 0 end
		if ent.hads then
			return 1
		else
			return 0
		end
	end
	return 0
end

--------------------------------------------------------------------------------

//set details
e2function entity entity:tardisGet()
	return TARDIS_Get(this)
end

e2function number entity:tardisDemat(vector pos)
	return TARDIS_Teleport(this, pos)
end
e2function number entity:tardisDemat(vector pos, angle rot)
	return TARDIS_Teleport(this, pos, rot)
end

e2function number entity:tardisPhase()
	return TARDIS_Phase(this)
end

e2function number entity:tardisFlightmode()
	return TARDIS_Flightmode(this)
end

e2function number entity:tardisLock()
	return TARDIS_Lock(this)
end

e2function number entity:tardisPhyslock()
	return TARDIS_Physlock(this)
end

e2function number entity:tardisPower()
	return TARDIS_Power(this)
end

e2function number entity:tardisIsomorph()
	return TARDIS_Isomorph(self,this)
end

e2function number entity:tardisLongflight()
	return TARDIS_Longflight(this)
end

e2function number entity:tardisMaterialise()
	return TARDIS_Materialise(this)
end

e2function number entity:tardisSelfrepair()
	return TARDIS_Selfrepair(this)
end

e2function number entity:tardisTrack(entity ent)
	return TARDIS_Track(this, ent)
end

e2function number entity:tardisSpinmode(number spinmode)
	return TARDIS_Spinmode(this,spinmode)
end

e2function number entity:tardisSetDestination(vector pos)
	return TARDIS_SetDestination(this, pos)
end

e2function number entity:tardisSetDestination(vector pos, angle rot)
	return TARDIS_SetDestination(this, pos, rot)
end

e2function number entity:tardisHADS()
	return TARDIS_HADS(this)
end

// get details
e2function number entity:tardisMoving()
	return TARDIS_Moving(this)
end

e2function number entity:tardisVisible()
	return TARDIS_Visible(this)
end

e2function number entity:tardisFlying()
	return TARDIS_Flying(this)
end

e2function number entity:tardisHealth()
	return TARDIS_Health(this)
end

e2function number entity:tardisLocked()
	return TARDIS_Locked(this)
end

e2function number entity:tardisPhyslocked()
	return TARDIS_Physlocked(this)
end

e2function number entity:tardisPowered()
	return TARDIS_Powered(this)
end

e2function number entity:tardisIsomorphic()
	return TARDIS_Isomorphic(this)
end

e2function number entity:tardisLongflighted()
	return TARDIS_Longflighted(this)
end

e2function number entity:tardisSelfrepairing()
	return TARDIS_Selfrepairing(this)
end

e2function vector entity:tardisLastPos()
	return TARDIS_LastPos(this)
end

e2function angle entity:tardisLastAng()
	return TARDIS_LastAng(this)
end

e2function entity entity:tardisTracking()
	return TARDIS_Tracking(this)
end

e2function number entity:tardisInVortex()
	return TARDIS_InVortex(this)
end

e2function number entity:tardisIsHADS()
	return TARDIS_IsHADS(this)
end