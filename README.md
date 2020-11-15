# FlyPaper

A library for sticking frames together

## Examples

```lua
local LibFlyPaper = LibStub("LibFlyPaper-1.1")

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

-- Attempts to attach <frame> to <otherFrame>
-- tolerance: how close the frames need to be to attach
-- xOff: horizontal spacing to include between each frame
-- yOff: vertical spacing to include between each frame
-- returns an anchor point if attached and nil otherwise
local anchor, distance = LibFlyPaper.Stick(frame, otherFrame, [tolerance, xOff, yOff])

-- Attempts to anchor frame to a specific anchor point on otherFrame
-- point: any non nil return value of LibFlyPaper.Stick
-- xOff: horizontal spacing to include between each frame
-- yOff: vertical spacing to include between each frame
-- returns an anchor point if attached and nil otherwise
local anchor = LibFlyPaper.StickToAnchor(frame, otherFrame, anchor, [xOff, yOff])

-- Iterates through all frames registered with FlyPaper and anchors to the
-- closest one that is within tolerance distance, if it exists
local anchor, group, id = LibFlyPaper.StickToClosestFrame(frame, [tolerance, xOff, yOff])

-- Iterates through all frames registered with FlyPaper within the specified
-- group and anchors to the closest one that is within tolerance distance
-- if it exists
local anchor, id = LibFlyPaper.StickToClosestFrameInGroup(frame, groupName, [tolerance, xOff, yOff])

-- registers the frame with FlyPaper
local registered = LibFlyPaper.AddFrame(groupName, id, frame)

-- unregisters the frame with flypaper
local uregistered = LibFlyPaper.RemoveFrame(groupName, id)

-- retrieves the specified frame, if it exists
local frame = LibFlyPaper.GetFrame(groupName, id)

-- retrieves the group information for the specified frame, if it exists
local groupName, id = LibFlyPaper.GetFrameInfo(frame)

-- retrieves the default sticky tolerance setting
local tolerance = LibFlyPaper.GetDefaultStickyTolerance()

--------------------------------------------------------------------------------
-- Callbacks
--------------------------------------------------------------------------------

local owner = {}

LibFlyPaper.AddCallback(owner, 'OnAnchorFrame')
LibFlyPaper.AddCallback(owner, 'OnAddFrame')
LibFlyPaper.AddCallback(owner, 'OnRemoveFrame')

-- called when a frame is registered with FlyPaper
-- frame: what frame was added
-- group: the group the frame was added to
-- id: the id of the frame within the group
function owner:OnAddFrame(msg, frame, groupName, id) end

-- called when a frame is unregistered from FlyPaper
-- frame: what frame was removed
-- group: the group the frame was removed to from
-- id: the id of the frame within the group
function owner:OnRemoveFrame(msg, frame, groupName, id) end

-- called when a frame is anchored to another frame
-- frame: what frame was anchored
-- relFrame: what frame the frame was anchored to
function owner:OnAnchorFrame(msg, frame, relFrame, anchor, xOff, yOff) end
```
