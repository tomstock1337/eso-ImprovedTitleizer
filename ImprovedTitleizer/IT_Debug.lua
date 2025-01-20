ImprovedTitleizer = ImprovedTitleizer or {}
local Imp = ImprovedTitleizer

local tos = tostring

--[[
  Global Window Events
]]
function Imp.GuiDebugOnResizeStop()
  Imp.GuiDebugSaveFrameInfo()
  if Imp.isDebugGuiLoading == true then
    return
  end
end
function Imp.GuiDebugSaveFrameInfo(calledFrom)
  --functions hooked from GUI can't be local
  local gui_s = Imp.savedVariables["guiDebug"]

  gui_s.lastX = ImprovedTitleizer_DebugGUI:GetLeft()
  gui_s.lastY = ImprovedTitleizer_DebugGUI:GetTop()
  gui_s.width = ImprovedTitleizer_DebugGUI:GetWidth()
  gui_s.height = ImprovedTitleizer_DebugGUI:GetHeight()
end
function Imp.RestoreDebugPosition()
  local control = ImprovedTitleizer_DebugGUI
  local gui_s = Imp.savedVariables["guiDebug"]
  local left = gui_s.lastX
  local top = gui_s.lastY

  control:SetHeight(gui_s.height)
  control:SetWidth(gui_s.width)

  control:ClearAnchors()
  control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end
--[[
    Global functions used by other addon callbacks or XML
]]
function Imp.Imp_DebugToggle()
  --functions hooked from other addons can't be local
  SCENE_MANAGER:ToggleTopLevel(ImprovedTitleizer_DebugGUI)
end
function Imp.Imp_DebugShow()
  --functions hooked from other addons can't be local
  SCENE_MANAGER:ShowTopLevel(ImprovedTitleizer_DebugGUI)
end

function Imp.Imp_DebugRefresh()
  local editCtrl = ImprovedTitleizer_DebugGUI_Edit
  editCtrl:Clear()
  editCtrl:SetMaxInputChars(100000)

  local lastCat = ''
  local isOrganized = false

  for _, item in ipairs(ImprovedTitleizer.AllTitles) do
    isOrganized = false

    for i,sub in pairs(ImprovedTitleizer.AchievmentIdsCategories) do
      for j,q in pairs(sub.Entries) do
        if q.ID == item.AchievementID then
          isOrganized = true
          break
        end
      end
      if isOrganized then
        break
      end
    end
    if not isOrganized then
      if tos(item.CategoryName)..'-'..tos(item.SubCategoryName) ~= lastCat then
        editCtrl:SetText(editCtrl:GetText() .. string.char(10) ..
        "---------"..tos(item.CategoryName)..'-'..tos(item.SubCategoryName).."---------")
        lastCat = tos(item.CategoryName)..'-'..tos(item.SubCategoryName)
      end
        editCtrl:SetText(editCtrl:GetText() .. string.char(10) ..
            "{ID="..tos(item.AchievementID) .. "}, --"..tos(item.AchievementName)..'-'..tos(item.Title)..'$$$$$'..tos(item.AchievementDescription))
      end
    end
end

function Imp.InitDebugGui()
  local control = ImprovedTitleizer_DebugGUI

  Imp.RestoreDebugPosition()

  SCENE_MANAGER:RegisterTopLevel(control, false)
end
