RefreshContracts = {}

RefreshContracts.debug = false --true --

function RefreshContracts:onFrameOpen()
    if RefreshContracts.debug then print("RefreshContracts:onFrameOpen") end

    local inGameMenu = g_currentMission.inGameMenu
    if inGameMenu.refreshContractsElement_Button == nil then
        -- Add a new docked button with a new action for refreshing the list
        local refreshContractsElement = inGameMenu.menuButton[1]:clone(self)
        refreshContractsElement:setText(g_i18n:getText("RefreshContracts_REFRESH"))
        refreshContractsElement:setInputAction("MENU_EXTRA_1")
        refreshContractsElement.onClickCallback = function(dialog)
            if RefreshContracts.debug then print("RefreshContracts:onClickCallback") end
            -- Set generationTimer to 0 so missions will be refresh at next update
            -- g_missionManager.generationTimer = 0
            g_missionManager:refreshMissions()
            if RefreshContracts.debug then
                print("RefreshContracts:generationTimer "..tostring(g_missionManager.generationTimer))
                print("#g_missionManager.missions "..tostring(#g_missionManager.missions))
                print("#g_missionManager.missions "..tostring(MissionManager.MAX_MISSIONS))
            end
        end

        inGameMenu.menuButton[1].parent:addElement(refreshContractsElement)
        inGameMenu.refreshContractsElement_Button = refreshContractsElement

        inGameMenu.onClickMenuExtra1 = Utils.overwrittenFunction(inGameMenu.onClickMenuExtra1, RefreshContracts.onClickMenuExtra1)

    end
end
InGameMenuContractsFrame.onFrameOpen = Utils.appendedFunction(InGameMenuContractsFrame.onFrameOpen, RefreshContracts.onFrameOpen)

-- For Dedicated Server debug
-- function RefreshContracts:generateMissions(dt)
--     if RefreshContracts.debug then print("RefreshContracts:generateMissions") end
-- end
-- MissionManager.generateMissions = Utils.appendedFunction(MissionManager.generateMissions, RefreshContracts.generateMissions)

function RefreshContracts:onFrameClose()
    if RefreshContracts.debug then print("RefreshContracts:onFrameClose") end

    local inGameMenu = g_currentMission.inGameMenu
    if inGameMenu.refreshContractsElement_Button ~= nil then
        inGameMenu.refreshContractsElement_Button:unlinkElement()
        inGameMenu.refreshContractsElement_Button:delete()
        inGameMenu.refreshContractsElement_Button = nil
    end
end
InGameMenuContractsFrame.onFrameClose = Utils.appendedFunction(InGameMenuContractsFrame.onFrameClose, RefreshContracts.onFrameClose)

---Due to how the input system works in fs19, the input is not only handled with a click callback but also via these events
function RefreshContracts.onClickMenuExtra1(dialog, superFunc, ...)
    if RefreshContracts.debug then print("RefreshContracts:onClickMenuExtra1") end
    if superFunc ~= nil then
        superFunc(dialog, ...)
    end

    dialog.refreshContractsElement_Button.onClickCallback(dialog)
end

function MissionManager:refreshMissions()
    -- print("MissionManager:refreshMissions")
	if g_currentMission:getIsServer() then
        -- print("called on Server")
        self.generationTimer = 0
	else
        -- print("called on Client")
		g_client:getServerConnection():sendEvent(RefreshContractsEvent.new())
	end
end
