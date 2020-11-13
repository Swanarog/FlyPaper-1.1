-- LibFlyPaper
-- Functionality for sticking one frome to another frame

-- Copyright 2020 Jason Greer

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

local LibFlyPaper = LibStub:NewLibrary('LibFlyPaper-1.1', 0)
if not LibFlyPaper then return end

local DEFAULT_STICKY_TOLERANCE = 16

-- returns frame points: left, right, top, bottom, hCenter, vCenter
local function GetPoints(frame)
	local l, b, w, h

	-- GetScaledRect may not exist in wow classic
	if frame.GetScaledRect then
		l, b, w, h = frame:GetScaledRect()
	else
		l, b, w, h = frame:GetRect()
		local s = frame:GetEffectiveScale()

		l = l * s
		b = b * s
		w = w * s
		h = h * s
	end

	return l, (l + w), (b + h), b, (l + w/2), (b + h/2)
end

-- all possible frame stratas (used for z distance calculations)
local FRAME_STRATAS = {
	BACKGROUND = 1,
	LOW = 2,
	MEDIUM = 3,
	HIGH = 4,
	DIALOG = 5,
	FULLSCREEN = 6,
	FULLSCREEN_DIALOG = 7,
	TOOLTIP = 8
}

-- all possible anchor points
local FRAME_ANCHORS = {
	-- bottom
	"TL",
	"TR",
	"TC",
	-- top
	"BL",
	"BR",
	"BC",
	-- right
	"LB",
	"LT",
	"LC",
	-- left
	"RB",
	"RT",
	"RC"
}

local FRAME_ANCHOR_POINTS = {
	-- top
	TL = {'BOTTOMLEFT', 'TOPLEFT', 0, 1},
	TR = {'BOTTOMRIGHT', 'TOPRIGHT', 0, 1},
	TC = {'BOTTOM', 'TOP', 0, 1},
	-- bottom
	BL = {'TOPLEFT', 'BOTTOMLEFT', 0, -1},
	BR = {'TOPRIGHT', 'BOTTOMRIGHT', 0, -1},
	BC = {'TOP', 'BOTTOM', 0, -1},
	-- left
	LB = {'BOTTOMRIGHT', 'BOTTOMLEFT', -1, 0},
	LT = {'TOPRIGHT', 'TOPLEFT', -1, 0},
	LC = {'RIGHT', 'LEFT', -1, 0},
	-- right
	RB = {'BOTTOMLEFT', 'BOTTOMRIGHT', 1, 0},
	RT = {'TOPLEFT', 'TOPRIGHT', 1, 0},
	RC = {'LEFT', 'RIGHT', 1, 0},
}

local FRAME_ANCHOR_DISTANCES = {
	TL = function(frame, otherFrame)
		local left, right, top, bottom, hCenter, vCenter = GetPoints(frame)
		local oLeft, oRight, oTop, oBottom, ohCenter, ovCenter = GetPoints(otherFrame)

		return (left - oLeft) ^ 2 + (bottom - oTop) ^ 2
	end,

	TR = function(frame, otherFrame)
		local left, right, top, bottom, hCenter, vCenter = GetPoints(frame)
		local oLeft, oRight, oTop, oBottom, ohCenter, ovCenter = GetPoints(otherFrame)

		return (right - oRight) ^ 2 + (bottom - oTop) ^ 2
	end,

	TC = function(frame, otherFrame)
		local left, right, top, bottom, hCenter, vCenter = GetPoints(frame)
		local oLeft, oRight, oTop, oBottom, ohCenter, ovCenter = GetPoints(otherFrame)

		return (hCenter - ohCenter) ^ 2 + (bottom - oTop) ^ 2
	end,

	BL = function(frame, otherFrame)
		local left, right, top, bottom, hCenter, vCenter = GetPoints(frame)
		local oLeft, oRight, oTop, oBottom, ohCenter, ovCenter = GetPoints(otherFrame)

		return (left - oLeft) ^ 2 + (top - oBottom) ^ 2
	end,

	BR = function(frame, otherFrame)
		local left, right, top, bottom, hCenter, vCenter = GetPoints(frame)
		local oLeft, oRight, oTop, oBottom, ohCenter, ovCenter = GetPoints(otherFrame)

		return (right - oRight) ^ 2 + (top - oBottom) ^ 2
	end,

	BC = function(frame, otherFrame)
		local left, right, top, bottom, hCenter, vCenter = GetPoints(frame)
		local oLeft, oRight, oTop, oBottom, ohCenter, ovCenter = GetPoints(otherFrame)

		return (hCenter - ohCenter) ^ 2 + (top - oBottom) ^ 2
	end,

	LB = function(frame, otherFrame)
		local left, right, top, bottom, hCenter, vCenter = GetPoints(frame)
		local oLeft, oRight, oTop, oBottom, ohCenter, ovCenter = GetPoints(otherFrame)

		return (right - oLeft) ^ 2 + (bottom - oBottom) ^ 2
	end,

	LT = function(frame, otherFrame)
		local left, right, top, bottom, hCenter, vCenter = GetPoints(frame)
		local oLeft, oRight, oTop, oBottom, ohCenter, ovCenter = GetPoints(otherFrame)

		return (right - oLeft) ^ 2 + (top - oTop) ^ 2
	end,

	LC = function(frame, otherFrame)
		local left, right, top, bottom, hCenter, vCenter = GetPoints(frame)
		local oLeft, oRight, oTop, oBottom, ohCenter, ovCenter = GetPoints(otherFrame)

		return (right - oLeft) ^ 2 + (vCenter - ovCenter) ^ 2
	end,

	RB = function(frame, otherFrame)
		local left, right, top, bottom, hCenter, vCenter = GetPoints(frame)
		local oLeft, oRight, oTop, oBottom, ohCenter, ovCenter = GetPoints(otherFrame)

		return (left - oRight) ^ 2 + (bottom - oBottom) ^ 2
	end,

	RT = function(frame, otherFrame)
		local left, right, top, bottom, hCenter, vCenter = GetPoints(frame)
		local oLeft, oRight, oTop, oBottom, ohCenter, ovCenter = GetPoints(otherFrame)

		return (left - oRight) ^ 2 + (top - oTop) ^ 2
	end,

	RC = function(frame, otherFrame)
		local left, right, top, bottom, hCenter, vCenter = GetPoints(frame)
		local oLeft, oRight, oTop, oBottom, ohCenter, ovCenter = GetPoints(otherFrame)

		return (left - oRight) ^ 2 + (vCenter - ovCenter) ^ 2
	end
}

-- returns true if <frame> or one of the frames that <frame> is dependent on
-- is anchored to <otherFrame> and nil otherwise
local function FrameIsDependentOnFrame(frame, otherFrame)
	if (frame and otherFrame) then
		if frame == otherFrame then
			return true
		end

		local points = frame:GetNumPoints()
		for i = 1, points do
			local parent = select(2, frame:GetPoint(i))
			if FrameIsDependentOnFrame(parent, otherFrame) then
				return true
			end
		end
	end
end

-- returns true if its actually possible to attach the two frames without error
local function CanAttach(frame, otherFrame)
	if not (frame and otherFrame) then
		return
	elseif FrameIsDependentOnFrame(otherFrame, frame) then
		return
	end
	return true
end

-- returns the addon id and addonName associated with the specified frame
local function GetRegisteredFrameInfo(frame)
	local registry = LibFlyPaper._registry
	if not registry then
		return
	end

	for addonName, addonRegistry in pairs(registry) do
		for addonKey, addonFrame in pairs(addonRegistry) do
			if addonFrame == frame then
				return addonKey, addonName
			end
		end
	end
end

local function GetADistance(frame, otherFrame)
	if frame == otherFrame then
		return 0
	end

	local _, addonName = GetRegisteredFrameInfo(frame)
	local _, otherAddonName = GetRegisteredFrameInfo(otherFrame)

	if addonName == otherAddonName then
		return 0
	end

	return 1
end

local function GetZDistance(frame, otherFrame)
	if frame == otherFrame then
		return 0
	end

	local s1 = FRAME_STRATAS[frame:GetFrameStrata()]
	local s2 = FRAME_STRATAS[otherFrame:GetFrameStrata()]

	local l1 = frame:GetFrameLevel()
	local l2 = otherFrame:GetFrameLevel()

	return (s1 - s2) ^ 2 + (l1 - l2) ^ 2
end

-- iterate through all anchor points
-- return the one with the shortest distance
local function GetClosestAnchor(frame, otherFrame)
	if frame == otherFrame then
		return
	end

	local bestDistance = math.huge
	local bestAnchor = false

	for i = 1, #FRAME_ANCHORS do
		local anchor = FRAME_ANCHORS[i]
		local distance = FRAME_ANCHOR_DISTANCES[anchor](frame, otherFrame)

		if distance < bestDistance then
			bestDistance = distance
			bestAnchor = anchor
		end
	end

	return bestAnchor, bestDistance
end

local function GetClosestFrameInRegistry(frame, registry, stickyTolerance)
	local stickyDistance = (tonumber(stickyTolerance) or DEFAULT_STICKY_TOLERANCE) ^ 2
	local bestAnchor, bestKey, bestFrame
	local bestDistance = math.huge

	for rKey, rFrame in pairs(registry) do
		if CanAttach(frame, rFrame) then
			local anchor, distance = GetClosestAnchor(frame, rFrame)

			if distance <= stickyDistance then
				-- prioritize frames on the same layer
				distance = distance + GetZDistance(frame, rFrame)

				-- prioritize frames from the same addon
				distance = distance + GetADistance(frame, rFrame)

				if distance < bestDistance then
					bestFrame = rFrame
					bestKey = rKey
					bestAnchor = anchor
					bestDistance = distance
				end
			end
		end
	end

	return bestFrame, bestAnchor, bestKey, bestDistance
end

local function AnchorFrameToFrame(frame, otherFrame, anchor, xOff, yOff)
	xOff = tonumber(xOff) or 0
	yOff = tonumber(yOff) or 0

	local point, relPoint, xMod, yMod = unpack(FRAME_ANCHOR_POINTS[anchor])

	frame:ClearAllPoints()

	frame:SetPoint(
		point,
		otherFrame,
		relPoint,
		xOff * xMod,
		yOff * yMod
	)
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

-- attempts to attach <frame> to <otherFrame>
-- tolerance: how close the frames need to be to attach
-- xOff: horizontal spacing to include between each frame
-- yOff: vertical spacing to include between each frame
-- returns an anchor point if attached and nil otherwise
function LibFlyPaper.Stick(frame, otherFrame, stickyTolerance, xOff, yOff)
	if not CanAttach(frame, otherFrame) then
		return
	end

	stickyTolerance = tonumber(stickyTolerance) or DEFAULT_STICKY_TOLERANCE
	xOff = tonumber(xOff) or 0
	yOff = tonumber(yOff) or 0

	local anchor, distance = GetClosestAnchor(frame, otherFrame)

	if distance <= (stickyTolerance ^ 2) then
		AnchorFrameToFrame(frame, otherFrame, anchor, xOff, yOff)

		return anchor, distance
	end
end

-- attempts to anchor frame to a specific anchor point on otherFrame
-- point: any non nil return value of LibFlyPaper.Stick
-- xOff: horizontal spacing to include between each frame
-- yOff: vertical spacing to include between each frame
-- returns an anchor point if attached and nil otherwise
function LibFlyPaper.StickToPoint(frame, otherFrame, anchor, xOff, yOff)
	-- check to make sure its actually possible to attach the frames
	if not (anchor and CanAttach(frame, otherFrame)) then
		return
	end

	AnchorFrameToFrame(frame, otherFrame, anchor, xOff, yOff)

	return anchor
end

-- iterate through all registered frames in namespace
function LibFlyPaper.StickToClosestFrame(frame, stickyTolerance, xOff, yOff)
	local registry = LibFlyPaper._registry
	if not registry then
		return
	end

	local bestAnchor, bestAddon, bestKey, bestFrame
	local bestDistance = math.huge

	for addonName in pairs(registry) do
		local addonFrame, addonAnchor, addonKey, addonDist = GetClosestFrameInRegistry(frame, registry, stickyTolerance)

		if addonDist < bestDistance then
			bestAddon = addonName
			bestFrame = addonFrame
			bestKey = addonKey
			bestAnchor = addonAnchor
			bestDistance = addonDist
		end
	end

	if bestFrame then
		AnchorFrameToFrame(frame, bestFrame, bestAnchor, xOff, yOff)

		return bestAnchor, bestAddon, bestKey, bestDistance
	end
end

-- iterate through all registered frames, and try to stick to the nearest one
function LibFlyPaper.StickToClosestAddonFrame(frame, addonName, stickyTolerance, xOff, yOff)
	local registry = LibFlyPaper._registry
	if not registry then
		return
	end

	local addonRegistry = registry[addonName]
	if not addonRegistry then
		return
	end

	local bestFrame, bestAnchor, bestKey, bestDistance = GetClosestFrameInRegistry(frame, addonRegistry, stickyTolerance)

	if bestFrame then
		AnchorFrameToFrame(frame, bestFrame, bestAnchor, xOff, yOff)

		return bestAnchor, bestKey, bestDistance
	end
end

function LibFlyPaper.AddFrame(addonName, key, frame)
	local registry = LibFlyPaper._registry
	if not registry then
		registry = {}
		LibFlyPaper._registry = registry
	end

	local addonRegistry = LibFlyPaper._registry[addonName]
	if not addonRegistry then
		addonRegistry = {}
		registry[addonName] = addonRegistry
	end

	if not addonRegistry[key] then
		addonRegistry[key] = frame
		-- TODO: call callback.OnAddFrame(addonName, id, frame)
		return true
	end
end

function LibFlyPaper.RemoveFrame(addonName, key, frame)
	local registry = LibFlyPaper._registry
	if not registry then
		return
	end

	local addonRegistry = LibFlyPaper._registry[addonName]
	if not addonRegistry then
		return
	end

	if addonRegistry[key] == frame then
		addonRegistry[key] = nil
		-- TODO: call callback.OnRemoveFrame(addonName, id, frame)
		return true
	end
end