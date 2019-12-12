-- Copyright 2019, Shadock
local addonName, addon = ...
local HoverTarget = addon

local HoverTargetFrame = CreateFrame("Button", "HoverTargetFrame", GameTooltip, "TargetFrameTemplate")

local isInit = false

local FRAME_OFFSET_X = 40
local FRAME_OFFSET_Y = 40
local UNIT_MOUSEOVER = "mouseover"

function HoverTargetFrame:Initialize ()
	self:SetScript("OnHide", self.OnHide)
	self:SetScript("OnEvent", self.OnEvent)
	self:SetScript("OnUpdate", self.OnUpdate)
	self:OnLoad()
end

function HoverTargetFrame:InitializePoint()
	local anchorRight = GameTooltip:GetRight() + FRAME_OFFSET_X
	local anchorBottom = GameTooltip:GetTop() + FRAME_OFFSET_Y

	self:SetParent(GameTooltip)
	self:ClearAllPoints()
	self:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMLEFT", anchorRight, anchorBottom)
	-- self:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", FRAME_OFFSET_X, FRAME_OFFSET_Y)
end

function HoverTargetFrame:OnLoad ()
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
	local totUnit = unit.."target"
	TargetFrame_OnLoad(self, unit)
	TargetFrame_CreateTargetofTarget (self, totUnit)
	UnitFrame_SetUnit(self, unit,  self.healthbar,  self.manabar)
	UnitFrame_SetUnit (self.totFrame, totUnit, self.totFrame.healthbar, self.totFrame.manabar)

	self.totFrame:SetScript("OnUpdate", TargetofTarget_Update)

	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
end

function HoverTargetFrame:MouseoverUnit ()
    local unit = UNIT_MOUSEOVER
	if not UnitExists(unit) then
		self.healthbar.lockValues = true
		self.manabar.lockValues = true
		if (self.totFrame) then
			self.totFrame.healthbar.lockValues = true
			self.totFrame.manabar.lockValues = true
		end
	else
		self:SetUnit(unit)
	end
end

function HoverTargetFrame:SetUnit (unit)
	if not UnitExists(unit) then
		return
	end

	if not self.isInit and not InCombatLockdown() then
		self:InitializePoint()
		self.isInit = true
	end

	self.healthbar.lockValues = false
	self.manabar.lockValues = false

	if (self.totFrame) then
		self.totFrame.healthbar.lockValues = false
		self.totFrame.manabar.lockValues = false
	end

	self:Target_Update()
end

-- Modified code from Blizzard's TargetFrame.lua to control in-combat execution
function HoverTargetFrame:Target_Update ()
	-- This check is here so the frame will hide when the target goes away
	-- even if some of the functions below are hooked by addons.
	if ( not UnitExists(self.unit) and not ShowBossFrameWhenUninteractable(self.unit) ) then
		if not InCombatLockdown() then
			self:Hide();
		end
	else
		if not InCombatLockdown() then
			self:Show();
		end

		-- Moved here to avoid taint from functions below
		if ( self.totFrame ) then
			self:TargetofTarget_Update(self.totFrame);
		end

		UnitFrame_Update(self);
		if ( self.showLevel ) then
			TargetFrame_CheckLevel(self);
		end
		TargetFrame_CheckFaction(self);
		if ( self.showClassification ) then
			TargetFrame_CheckClassification(self);
		end
		TargetFrame_CheckDead(self);
		TargetFrame_CheckDishonorableKill(self);
		if ( self.showLeader ) then
			if ( UnitLeadsAnyGroup(self.unit) ) then
				self.leaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon");
				self.leaderIcon:SetTexCoord(0, 1, 0, 1);
				self.leaderIcon:Show();
			else
				self.leaderIcon:Hide();
			end
		end
		TargetFrame_UpdateAuras(self);
		if ( self.portrait ) then
			self.portrait:SetAlpha(1.0);
		end
		TargetFrame_CheckBattlePet(self);
		if ( self.petBattleIcon ) then
			self.petBattleIcon:SetAlpha(1.0);
		end
	end
end

-- Modified code from Blizzard's TargetFrame.lua to control in-combat execution
function HoverTargetFrame:TargetofTarget_Update (self, elapsed)
	local show;
	local parent = self:GetParent();
	if ( SHOW_TARGET_OF_TARGET == "1" and UnitExists(parent.unit) and UnitExists(self.unit) and ( not UnitIsUnit(PlayerFrame.unit, parent.unit) ) and ( UnitHealth(parent.unit) > 0 ) ) then
		if ( not self:IsShown() ) then
			if not InCombatLockdown() then
				self:Show();
			end
			if ( parent.spellbar ) then
				parent.haveToT = true;
				Target_Spellbar_AdjustPosition(parent.spellbar);
			end
		end
		UnitFrame_Update(self);
		TargetofTarget_CheckDead(self);
		TargetofTargetHealthCheck(self);
		RefreshDebuffs(self, self.unit, nil, nil, true);
	else
		if ( self:IsShown() ) then
			if not InCombatLockdown() then
				self:Hide();
			end
			if ( parent.spellbar ) then
				parent.haveToT = nil;
				Target_Spellbar_AdjustPosition(parent.spellbar);
			end
		end
	end
end

function HoverTargetFrame:OnHide ()
	if InCombatLockdown() then
		return
	end
	self:SetParent(nil)
	self:Hide()
	self.isInit = false
end

function HoverTargetFrame:OnUpdate (elapsed)
	local unit = UNIT_MOUSEOVER
	if UnitExists(unit) and not InCombatLockdown() then
		TargetFrame_OnUpdate(self, elapsed)
	end
end

function HoverTargetFrame:OnEvent (event, ...)
	if ( event == "UPDATE_MOUSEOVER_UNIT" ) then
		self:MouseoverUnit()
	end
end

hooksecurefunc("GameTooltip_ClearInsertedFrames", function (self)
	if not InCombatLockdown() then
		HoverTargetFrame:Hide()
	end
end)

HoverTargetFrame:Initialize()
