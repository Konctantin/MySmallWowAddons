local CurrentRealm = GetRealmName() or "";
local CurrentPlayer = UnitName("player") or "<none>";
local CurentFullPlayerName = CurrentPlayer .. " - " .. CurrentRealm;

local function DumpAllCurrencies()
	if not CURRENCIES_DUMP_ALL then
		CURRENCIES_DUMP_ALL = { }
	end

	local playerInfo = CURRENCIES_DUMP_ALL[CurentFullPlayerName] or { };
	playerInfo.Name = CurrentPlayer;
	playerInfo.Realm = CurrentRealm;
	playerInfo.Class = select(2, UnitClass("player"));
	playerInfo.Currencies = { };

	-- probably id's range
	for id = 1, 5000 do
		local info = C_CurrencyInfo.GetCurrencyInfo(id);
		if info and info.quantity then
			playerInfo.Currencies[id] = info.quantity;
		end
	end

	CURRENCIES_DUMP_ALL[CurentFullPlayerName] = playerInfo;
end

local function AddAltCurrencies(tooltip, id)
	if CURRENCIES_DUMP_ALL then
		local playerList = { };
		local total = C_CurrencyInfo.GetCurrencyInfo(id).quantity;

		for name, info in pairs(CURRENCIES_DUMP_ALL) do
			if info.Realm == CurrentRealm and name ~= CurentFullPlayerName then
				local amount = info.Currencies[id] or 0;
				if amount > 0 then
					total = total + amount;
					table.insert(playerList, { Name = info.Name, Class = info.Class, Amount = amount });
				end
			end
		end
		table.sort(playerList, function(a, b) return a.Name < b.Name end);

		if #playerList > 0 then
			tooltip:AddDoubleLine("===", "===");

			for _, info in ipairs(playerList) do
				local clr = RAID_CLASS_COLORS[info.Class];
				tooltip:AddDoubleLine(info.Name,
					tostring(info.Amount),
					clr.r, clr.g, clr.b,
					0.5, 0.5, 0.5)
			end

			tooltip:AddDoubleLine("TOTAL",
						total,
						0.7, 0.7, 0.7,
						0.7, 0.7, 0.7)
		end
	end
	tooltip:Show()
end

local frame = CreateFrame("frame");
frame:SetScript("OnEvent", function(...) DumpAllCurrencies() end);
frame:RegisterEvent("PLAYER_LEAVING_WORLD");

-- Currencies
hooksecurefunc(GameTooltip, "SetCurrencyToken", function(self, index)
	local id = tonumber(string.match(C_CurrencyInfo.GetCurrencyListLink(index), "currency:(%d+)"))
	AddAltCurrencies(self, id)
end)

hooksecurefunc(GameTooltip, "SetCurrencyByID", function(self, id)
	AddAltCurrencies(self, id)
end)

hooksecurefunc(GameTooltip, "SetCurrencyTokenByID", function(self, id)
	AddAltCurrencies(self, id)
end)
