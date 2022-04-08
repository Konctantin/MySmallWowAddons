local addonName, T = ...;
_G[addonName] = T;

T.MainFrame = CreateFrame("Frame");
T.MainFrame:RegisterEvent("ADDON_LOADED");
T.MainFrame:SetScript("OnEvent",
function(_, _, addon)
    if addon == addonName then
        T.oldBossBanner_OnEvent = BossBanner_OnEvent;
        if T.oldBossBanner_OnEvent then
            BossBanner_OnEvent = function(frame, event, ...)
                if event == "BOSS_KILL" or event == "ENCOUNTER_LOOT_RECEIVED" then
                    return frame, event, ...;
                end
                return T.oldBossBanner_OnEvent(frame, event, ...);
            end
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
    elseif addon == "Blizzard_TalkingHeadUI" then
        hooksecurefunc("TalkingHeadFrame_PlayCurrent", function()
            if TalkingHeadFrame then
                TalkingHeadFrame:Hide();
            end
        end);
    end
end);
