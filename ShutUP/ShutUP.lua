local addonName, T = ...;
_G[addonName] = T;

local oldBossBanner_OnEvent = nil;

T.MainFrame = CreateFrame("Frame");
T.MainFrame:RegisterEvent("ADDON_LOADED");
T.MainFrame:SetScript("OnEvent",
function(_, _, addon)
    --print(addon)
    if addon == addonName then
        oldBossBanner_OnEvent = BossBanner_OnEvent;

        BossBanner_OnEvent = function(frame, event, ...)
            if (event == "BOSS_KILL" or event == "ENCOUNTER_LOOT_RECEIVED" ) and oldBossBanner_OnEvent then
                return frame, event, ...;
            end
            return oldBossBanner_OnEvent(frame, event, ...);
        end

        CinematicFrame:HookScript("OnShow", function(...)
            if not IsModifierKeyDown() then
                CinematicFrame_CancelCinematic();
                print("Cinematic Canceled.");
            end
        end);

        MovieFrame_PlayMovie = function(...)
            if not IsModifierKeyDown() then
                GameMovieFinished();
                print("Movie Canceled.");
                return true;
            end
        end
    end
end);
