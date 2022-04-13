local addonName, T = ...;
_G[addonName] = T; -- make it public

local BUTTON_SIZE  = 32;
local BUTTON_Y_POS = 40;
local BUTTON_X_POS =-30;
local BUTTON_SHIFT = 40;

local UP_ITEMS = {
    188655, -- Crystalline Memory Repository
    188656, -- Fractal Thoughtbinder
    188657, -- Mind-Expanding Prism
    --186472  -- Wisps of Memory
};

local Events = { };
local frame = CreateFrame("Frame");

local function CreateUPButton(place, itemID, xpos, frameName)
    local itemName, itemLink = GetItemInfo(itemID);
    if not itemName then
        return;
    end
    local buttonName = "UpButton_"..tostring(itemID);
    if not place[buttonName] then
        local macrotext = "/use "..itemName.."\n/run C_Garrison.CastSpellOnFollower("..frameName..".FollowerTab.followerID)";

        local button = CreateFrame("Button", buttonName, place, "SecureActionButtonTemplate,ActionButtonTemplate");
        button:SetSize(BUTTON_SIZE, BUTTON_SIZE);
        button:SetPoint("BOTTOMRIGHT", xpos, BUTTON_Y_POS);

        local icon = button:CreateTexture(nil, "ARTWORK");
        icon:SetAllPoints();
        icon:SetTexture(GetItemIcon(itemID));
        button.Icon = icon;

        button:HookScript("OnEnter", function()
            GameTooltip:SetOwner(button, "ANCHOR_TOP");
            GameTooltip:SetHyperlink(itemLink);
            GameTooltip:Show();
        end);

        button:HookScript("OnLeave", function()
            GameTooltip:Hide();
        end)

        button:SetAttribute("type", "macro");
        button:SetAttribute("macrotext", macrotext);
        button:RegisterForClicks("LeftButtonUp");
        place[buttonName] = button;
    end

    local count = GetItemCount(itemID);

    local level = 60;
    local missionCompleteInfo = C_Garrison.GetFollowerMissionCompleteInfo(place.followerID);
    if missionCompleteInfo then
        level = missionCompleteInfo.level;
    end

    local enabled = level < 60;

    place[buttonName].Count:SetText(count);
    place[buttonName]:SetEnabled(enabled);
end

local function UpdateAllButtons(place, frameName)
    if place and place.followerID then
        local xpos = BUTTON_X_POS;
        for _, itemID in ipairs(UP_ITEMS) do
            CreateUPButton(place, itemID, xpos, frameName);
            xpos = xpos - BUTTON_SHIFT;
        end
    end
end

local function Setup(place)
    local parent = place:GetParent();
    local frameName = parent:GetName();

    local followerID = place.followerID;
    if not followerID then
        return;
    end

    local followerInfo = C_Garrison.GetFollowerInfo(followerID)
    if not followerInfo or followerInfo.followerTypeID ~= 123 then
        return;
    end

    UpdateAllButtons(place, frameName);

    C_Timer.After(0.3, function()
        if parent and not parent.CounterFrame then
            local frame = CreateFrame("Frame");
            frame:RegisterEvent("BAG_UPDATE");
            frame:RegisterEvent("BAG_NEW_ITEMS_UPDATED");
            frame:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED");
            --frame:RegisterEvent("GARRISON_FOLLOWER_LEVEL_UP");
            frame:SetScript("OnEvent",
                function()
                    if place and frameName and place.followerID then
                        UpdateAllButtons(place, frameName)
                    end
                end);
            frame:Show();
            parent.CounterFrame = frame;
        end
    end);
end

local function ShowHook(self)
    Setup(self);
end

local function HideHook(self)
    local parent = self:GetParent();
    if parent and parent.CounterFrame then
        parent.CounterFrame:UnregisterAllEvents();
        parent.CounterFrame = nil;
    end
end

function Events.ADDON_LOADED(addon)
    if addon == "Blizzard_GarrisonUI" and not frame.IsLoaded then
        hooksecurefunc(CovenantMissionFrame.FollowerTab, "ShowFollower", ShowHook);
        hooksecurefunc(CovenantMissionFrame.FollowerTab, "Hide", HideHook);
        hooksecurefunc(GarrisonLandingPage.FollowerTab, "ShowFollower", ShowHook);
        hooksecurefunc(GarrisonLandingPage.FollowerTab, "Hide", HideHook);
        frame.IsLoaded = true;
    end
end

for event in pairs(Events) do
    frame:RegisterEvent(event);
end

frame:SetScript("OnEvent",
    function(_, event, ...)
        local handler = Events[event];
        if handler then
            handler(...);
        end
    end);
frame:Show();

T.MainFrame = frame;
