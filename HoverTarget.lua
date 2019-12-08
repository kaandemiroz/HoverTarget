-- Copyright 2019, Shadock
local FRAME_OFFSET_X = 40
local FRAME_OFFSET_Y = 40
local UNIT_MOUSEOVER = "mouseover"

function HoverTargetFrame_OnLoad (self)
	self:SetWidth(TargetFrame:GetWidth())
	self:SetHeight(TargetFrame:GetHeight())

	self:SetFrameStrata(GameTooltip:GetFrameStrata())

	self.buffsOnTop = TargetFrame.buffsOnTop
	self.noTextPrefix = TargetFrame.noTextPrefix
	self.showPortrait = TargetFrame.showPortrait
	self.showLevel = TargetFrame.showLevel
	self.showClassification = TargetFrame.showClassification
	self.showLeader = TargetFrame.showLeader
	self.showThreat = TargetFrame.showThreat
	self.showPVP = TargetFrame.showPVP
	self.showAuraCount = TargetFrame.showAuraCount
	self.showCastbar = TargetFrame.showCastbar

    local unit = UNIT_MOUSEOVER
	TargetFrame_OnLoad(self, unit);
	TargetFrame_CreateTargetofTarget(self, unit.."target");

	self.totFrame:SetScript("OnUpdate", HoverTargetofTarget_Update)
	self.totFrame:SetScript("OnHide", HoverTargetofTarget_OnHide)

	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
end

function HoverTargetFrame_MouseoverUnit (self)
    local unit = UNIT_MOUSEOVER
	if not UnitExists(unit) then
		self.healthbar.lockValues = true
		self.manabar.lockValues = true
		if (self.totFrame) then
			self.totFrame.healthbar.lockValues = true
			self.totFrame.manabar.lockValues = true
		end
	else
		HoverTargetFrame_SetUnit(self, unit)
	end
end

function HoverTargetFrame_SetUnit (self, unit)
	if not UnitExists(unit) then
		return
	end

	HoverTargetFrame_InsertToTooltip(self, GameTooltip)

	self.healthbar.lockValues = false
	self.manabar.lockValues = false
	UnitFrame_SetUnit(self, unit,  self.healthbar,  self.manabar)

	local totUnit = unit.."target"
	if (self.totFrame) then
		self.totFrame.healthbar.lockValues = false
		self.totFrame.manabar.lockValues = false
		UnitFrame_SetUnit (self.totFrame, totUnit, self.totFrame.healthbar, self.totFrame.manabar)
	end

	TargetFrame_Update(self)
end

function HoverTargetFrame_InsertToTooltip (self, tooltipFrame)
	local anchorRight = GameTooltip:GetRight() + FRAME_OFFSET_X
	local anchorBottom = GameTooltip:GetTop() + FRAME_OFFSET_Y

	self:SetParent(tooltipFrame)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", anchorRight, anchorBottom)

	if ( not tooltipFrame.insertedFrames ) then
		tooltipFrame.insertedFrames = { };
	end
	local frameWidth = self:GetWidth();
	if (tooltipFrame:GetMinimumWidth() < frameWidth) then
		tooltipFrame:SetMinimumWidth(frameWidth);
	end
	tinsert(tooltipFrame.insertedFrames, self);
end

function HoverTargetFrame_OnUpdate (self, elapsed)
	local unit = UNIT_MOUSEOVER
	if UnitExists(unit) then
		TargetFrame_OnUpdate(self, elapsed)
	end
end

function HoverTargetFrame_OnEvent (self, event, ...)
	if ( event == "UPDATE_MOUSEOVER_UNIT" ) then
		HoverTargetFrame_MouseoverUnit(self)
	end
end

function HoverTargetFrame_OnHide (self)
	-- Do nothing
end

function HoverTargetofTarget_Update (self)
	if UnitExists(self.unit) then
		TargetofTarget_Update(self)
	end
end

function HoverTargetofTarget_OnHide (self)
	-- Do nothing
end
