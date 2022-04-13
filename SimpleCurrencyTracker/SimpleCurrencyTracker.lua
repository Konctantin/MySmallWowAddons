local addonName, T = ...;
_G[addonName] = T;

if not SCT_CURRENCY_DUMP then
    SCT_CURRENCY_DUMP = { };
end

if not SCT_CURRENCY_CACHE then
    SCT_CURRENCY_CACHE = { Build = 0, CurrencyList = {} };
end

local function MakeCyrrencyCache()
    local build = select(2, GetBuildInfo());
    if SCT_CURRENCY_CACHE.Build ~= build then
        SCT_CURRENCY_CACHE.CurrencyList = {};
        for id = 1, 5000 do
            local currency = C_CurrencyInfo.GetCurrencyInfo(id);
            if currency then
                table.insert(SCT_CURRENCY_CACHE.CurrencyList, id);
            end
        end

        SCT_CURRENCY_CACHE.Build = build;
    end
end

local function GetCurrentPlayerInfo()
    local realm = GetRealmName() or "";
    local name = UnitName("player") or "<none>";
    local class = select(2, UnitClass("player"));
    local fullName = name.." - "..realm;
    return { Realm = realm, Name = name, Class = class, FullName = fullName };
end

local function DumpAllCurrencies()
    local playerInfo = T.PlayerInfo;
    if not playerInfo then
        return;
    end

    local info = SCT_CURRENCY_DUMP[playerInfo.FullName]
        or {
            Name  = playerInfo.Name,
            Realm = playerInfo.Realm,
            Class = playerInfo.Class
        };

    info.Currencies = { };
    MakeCyrrencyCache();
    for _, id in ipairs(SCT_CURRENCY_CACHE.CurrencyList) do
        local currency = C_CurrencyInfo.GetCurrencyInfo(id);
        if currency and currency.quantity > 0 then
            info.Currencies[id] = currency.quantity;
        end
    end

    SCT_CURRENCY_DUMP[playerInfo.FullName] = info;
end

local function AddAltCurrencies(tooltip, id)
    if SCT_CURRENCY_DUMP then
        local playerInfo = T.PlayerInfo;
        if not playerInfo then
            return;
        end

        local playerList = { };
        local total = C_CurrencyInfo.GetCurrencyInfo(id).quantity;

        for name, info in pairs(SCT_CURRENCY_DUMP) do
            if info.Currencies and name ~= playerInfo.FullName then
                local amount = info.Currencies[id] or 0;
                if amount > 0 then
                    total = total + amount;
                    table.insert(playerList, { Name = info.Name, FullName = name, Class = info.Class, Amount = amount });
                end
            end
        end
        table.sort(playerList, function(a, b) return a.Name < b.Name end);

        if #playerList > 0 then
            tooltip:AddDoubleLine("===", "===");

            for _, info in ipairs(playerList) do
                local clr = RAID_CLASS_COLORS[info.Class];
                tooltip:AddDoubleLine(info.FullName,
                    tostring(info.Amount),
                    clr.r, clr.g, clr.b,
                    0.5, 0.5, 0.5)
            end

            tooltip:AddDoubleLine("TOTAL", total, 0.7, 0.7, 0.7, 0.7, 0.7, 0.7);
        end
    end
    tooltip:Show()
end

local frame = CreateFrame("frame");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_LEAVING_WORLD");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "PLAYER_LEAVING_WORLD" then
        DumpAllCurrencies();
    elseif event == "PLAYER_ENTERING_WORLD" then
        T.PlayerInfo = GetCurrentPlayerInfo();
    elseif event == "ADDON_LOADED" and arg1 == addonName then
        MakeCyrrencyCache();

        hooksecurefunc(GameTooltip, "SetCurrencyToken", function(self, index)
            local id = tonumber(string.match(C_CurrencyInfo.GetCurrencyListLink(index), "currency:(%d+)"))
            AddAltCurrencies(self, id);
        end);
        hooksecurefunc(GameTooltip, "SetCurrencyByID", function(...)
            AddAltCurrencies(...);
        end);
        hooksecurefunc(GameTooltip, "SetCurrencyTokenByID", function(...)
            AddAltCurrencies(...);
        end);
    end
end);
