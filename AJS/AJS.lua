local addonName, T = ...;
_G[addonName] = T;

if not AJS_IGNORED_ITEMS then
    AJS_IGNORED_ITEMS = { };
end

T.Frame = CreateFrame("Frame");
T.Frame:RegisterEvent("MERCHANT_SHOW");
T.Frame:SetScript("OnEvent", function()
    for bag = 0, 5 do
        for slot = 1, GetContainerNumSlots(bag) or 0 do
            local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bag, slot);
            if quality == 0 and not noValue and not locked and not AJS_IGNORED_ITEMS[itemID] then
                UseContainerItem(bag, slot);
            end
        end
    end
end);

SLASH_AJSA1= '/ajsa'
function SlashCmdList.AJSA(msg)
    local id = tonumber(string.match(msg, "item:(%d+)")) or 0;
    if id > 0 then
        AJS_IGNORED_ITEMS[id] = 1;
        print("Add", select(2, GetItemInfo(id)));
    end
end

SLASH_AJSD1= '/ajsd'
function SlashCmdList.AJSD(msg)
    local id = tonumber(string.match(msg, "item:(%d+)")) or 0;
    if id > 0 then
        AJS_IGNORED_ITEMS[id] = nil;
        print("Removed", select(2, GetItemInfo(id)));
    end
end
