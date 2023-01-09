local Addon = {}
Addon.Name = "ImprovedTitleizer"
Addon.DisplayName = "ImprovedTitleizer"
Addon.Author = "tomstock"
Addon.Version = "1.0"

local AVA_SORT_BY_RANK =
{
    ["name"] = {},
    ["rank"] = {tiebreaker = "name", isNumeric = true},
}

local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

--These are actually their respective achievementIds
local AchievmentIdsCategories =
{
	{
		Name="Alliance War",
		Entries=
		{
			{ID=92,Rank=1}, --Volunteer
			{ID=93,Rank=2}, --Recruit
			{ID=94,Rank=3}, --Tyro
			{ID=95,Rank=4}, --Legionary
			{ID=96,Rank=5}, --Veteran
			{ID=97,Rank=6}, --Corporal
			{ID=98,Rank=7}, --Sergeant
			{ID=706,Rank=8}, --First Sergeant
			{ID=99,Rank=9}, --Lieutenant
			{ID=100,Rank=10}, --Captain
			{ID=101,Rank=11}, --Major
			{ID=102,Rank=12}, --Centurion
			{ID=103,Rank=13}, --Colonel
			{ID=104,Rank=14}, --Tribune
			{ID=105,Rank=15}, --Brigadier
			{ID=106,Rank=16}, --Prefect
			{ID=107,Rank=17}, --Praetorian
			{ID=108,Rank=18}, --Palatine
			{ID=109,Rank=19}, --August Palatine
			{ID=110,Rank=20}, --Legate
			{ID=111,Rank=21}, --General
			{ID=112,Rank=22}, --Warlord
			{ID=113,Rank=23}, --Grand Warlord
			{ID=114,Rank=24}, --Overlord
			{ID=705,Rank=25}, --Grand Overlord
		},
	},
	{
		Name="Battlegrounds",
		Entries=
		{
			{ID=1918}, -- [Paragon] Paragon
			{ID=1915}, -- [Battleground Butcher] Battleground Butcher
			{ID=1913}, -- [Grand Champion] Grand Champion
			{ID=1916}, -- [Tactician] Tactician
			{ID=1919}, -- [Triple Threat] Relic Runner
			{ID=1910}, -- [Conquering Hero] Conquering Hero
			{ID=1895}, -- [Pit Hero] Bloodletter
			{ID=1901}, -- [Grand Relic Guardian] Relic Guardian
			{ID=1898}, -- [Grand Relic Hunter] Relic Hunter
			{ID=1904}, -- [Grand Standard-Bearer] Standard-Bearer
			{ID=1907}, -- [Grand Standard-Guardian] Standard-Guardian
			{ID=1921}, -- [Quadruple Kill] The Merciless
		}
	},
	{
		Name="Tales of Tribute",
		Entries={
		{ID=3349, Rank=1}, -- Roister's Club Initiate
		{ID=3350, Rank=2}, -- Roister's Club Trainee
		{ID=3351, Rank=3}, -- Roister's Club Novice
		{ID=3352, Rank=4}, -- Roister's Club Regular
		{ID=3353, Rank=5}, -- Roister's Club Adept
		{ID=3354, Rank=6}, -- Roister's Club Expert
		{ID=3355, Rank=7}, -- Roister's Club Veteran
		{ID=3356, Rank=8}, -- Roister's Club Master
		}
	}
}

local AllTitles={};
--{TitleID=id, CategoryID=categoryId, CategoryName=categoryName,SubCategoryID=subCategory,SubCategoryName=subCategoryName,HasTitle=hasTitle}

local GetNumAchievementCategories        = GetNumAchievementCategories
--Usage: local numAchieveCategory = GetNumAchievementCategories()
local GetAchievementCategoryInfo         = GetAchievementCategoryInfo
--Usage: local categoryName, numSubCategories, numAchievements, earnedPoints, totalPoints = GetAchievementCategoryInfo(categoryIndex)
local GetFirstAchievementInLine          = GetFirstAchievementInLine
--Usage: local firstAchievementId = GetFirstAchievementInLine(achievementID)
local GetAchievementRewardTitle          = GetAchievementRewardTitle
--Usage: local hasRewardTitle, titleName = GetAchievementRewardTitle(achievementId)
local GetNextAchievementInLine           = GetNextAchievementInLine
--Usage: nextAchievementId = GetNextAchievementInLine(achievementId)
local GetAchievementSubCategoryInfo      = GetAchievementSubCategoryInfo
--Usage: local subCategoryName, subNumAchievements = GetAchievementSubCategoryInfo(categoryIndex, subCategoryIndex)
local GetAchievementId                   = GetAchievementId

--Usage: achievementId = GetAchievementId(categoryIndex, subcategoryIndex, achievementIndex)
local GetTitle                           = GetTitle -- I want original titles
--Usage: local strTitle GetTitle(achievementId)

local function InitializeTitles()

	local function CheckAchievementsInLine(id, categoryId, categoryName, subCategory, subCategoryName)
		--Go through every achievement looking for if a title exists for it.
		local firstId = GetFirstAchievementInLine(id)
		id = firstId > 0 and firstId or id
		while id > 0 do
			local hasTitle, title = GetAchievementRewardTitle(id)
			if hasTitle then
				local achieveName = GetAchievementNameFromLink(GetAchievementLink(id))
				table.insert(AllTitles,1,{TitleID=id,Title=title,CategoryID=categoryId, CategoryName=categoryName,SubCategoryID=subCategory,SubCategoryName=subCategoryName,HasTitle=hasTitle,AchievementName=achieveName},1);
			end
			id = GetNextAchievementInLine(id)
		end
	end
	for i=1,GetNumAchievementCategories() do
		local categoryName, numSubCategories, numAchievements, earnedPoints, totalPoints = GetAchievementCategoryInfo(i)
		for j=1,numAchievements do
			CheckAchievementsInLine(GetAchievementId(i,nil,j), i, categoryName)
		end

		for j=1,numSubCategories do
			local subCategoryName, subNumAchievements = GetAchievementSubCategoryInfo(i, j)
			for k=1,subNumAchievements do
				CheckAchievementsInLine(GetAchievementId(i,j,k), i, categoryName, j,subCategoryName)
			end
		end
	end
	for i,sub in pairs(AchievmentIdsCategories) do
		if (sub.Name=="Alliance War") then
			for j,rank in pairs(sub.Entries) do
				rank.Icon="|t28:28:"..GetAvARankIcon(j*2).."|t "
			end
		end
	end
end

local function OnLoad(eventCode, name)
	local debug = true
	if name ~= Addon.Name then return end

	InitializeTitles()

	local LSM = LibStub("LibScrollableMenu")

	local orgAddDropdownRow = STATS.AddDropdownRow
	STATS.AddDropdownRow = function(self, rowName)
		local control = orgAddDropdownRow(self, rowName)
		control.combobox = control:GetNamedChild("Dropdown")
		control.scrollHelper = LSM.ScrollableDropdownHelper:New(self.control, control, 16)
		STATS_SCENE:RegisterCallback("StateChange", OnStateChange)
		control.scrollHelper.OnShow = function() end --don't change parenting

		titlesRow = control
		return control
	end

	local function ComboBoxSortHelper(item1, item2, comboBoxObject, sortKey, sortType, sortOrder)
		return ZO_TableOrderingFunction(item1, item2, sortKey or "name", sortType or comboBoxObject.m_sortType, sortOrder or comboBoxObject.m_sortOrder)
	end

	local function UpdateTitleDropdownTitles(self, dropdown)
		local debug = false
		dropdown:ClearItems()
		dropdown:AddItem(ZO_ComboBox:CreateItemEntry(GetString(SI_STATS_NO_TITLE), function() SelectTitle(nil) end), ZO_COMBOBOX_SUPRESS_UPDATE)

		local menu = {}
		local subMenus={}
		for i,sub in pairs(AchievmentIdsCategories) do
			subMenus[sub.Name]={Entries={}}
		end
		for i,vTitle in pairs(AllTitles) do
			local titlePlaced = false
			local toolTip = vTitle.AchievementName.."\n"..vTitle.CategoryName
			if debug==true then
				toolTip = toolTip.."\n"..vTitle.TitleID
			end
			for k, vCategory in pairs(AchievmentIdsCategories) do
				for j,q in pairs(vCategory.Entries) do
					if vTitle.TitleID==q.ID then
						table.insert(subMenus[vCategory.Name].Entries,{name=(q.Icon or "")..vTitle.Title, rank=q.Rank or 0, callback=function() SelectTitle(vTitle.TitleID) end,tooltip=toolTip})
						titlePlaced=true
					end
				end
			end
			if(titlePlaced==false) then
				table.insert(menu,{name=vTitle.Title, rank = 0, callback=function() SelectTitle(vTitle.TitleID) end,tooltip=toolTip})
			end
		end
		table.sort(menu, function(item1, item2) return ComboBoxSortHelper(item1, item2, dropdown) end)

		local i = 1
		for header, titles in spairs(subMenus) do
			table.sort(titles.Entries, function(item1, item2) return ComboBoxSortHelper(item1, item2, dropdown, "rank",AVA_SORT_BY_RANK) end)
			table.insert(menu, i, {name=header, entries=titles.Entries})
			i = i + 1
		end
		-- add divider below "No Title" if there is more
		if #menu > 0 then
			table.insert(menu, 1, {name=LSM.DIVIDER})
			i = i + 1
		end
		-- add divider below last submenu if there is more
		if i <= #menu then
			table.insert(menu, i, {name=LSM.DIVIDER})
		end
		dropdown:AddItems(menu)

		self:UpdateTitleDropdownSelection(dropdown)
	end

	-- Old function from before 8.2.5
	-- New function gets the selected item by string value, new function selects by index (which is scambled due to the sorting)
	function UpdateTitleDropdownSelection(self, dropdown)
    local currentTitleIndex = GetCurrentTitleIndex()
    if currentTitleIndex then
        dropdown:SetSelectedItemText(zo_strformat(GetTitle(currentTitleIndex), GetRawUnitName("player")))
    else
        dropdown:SetSelectedItemText(GetString(SI_STATS_NO_TITLE))
    end
	end

	if STATS and STATS.UpdateTitleDropdownTitles then
		STATS.UpdateTitleDropdownTitles = UpdateTitleDropdownTitles
		STATS.UpdateTitleDropdownSelection = UpdateTitleDropdownSelection
	end

	EVENT_MANAGER:UnregisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED)
end
EVENT_MANAGER:RegisterForEvent(Addon.Name, EVENT_ADD_ON_LOADED, OnLoad)

IMPROVEDTITLEIZER = Addon

SLASH_COMMANDS["/dumptitles"] = function()
	for i=1,GetNumAchievementCategories() do
		local categoryName,numSubCategories,numAchievements, earnedPoints, totalPoints = GetAchievementCategoryInfo(i)
		d("#=Category Name: "..categoryName)
		for j=1,numAchievements do
			local id = GetAchievementId(i,nil,j)
			if (GetAchievementRewardTitle(id)) then
				d("#"..id.." "..GetAchievementLink(id).." "..select(2, GetAchievementRewardTitle(id)))
			end
		end

		for j=1,numSubCategories do
			local subCategoryName,subNumAchievements = GetAchievementSubCategoryInfo(i,j)
			for k=1,subNumAchievements do
				local id = GetAchievementId(i,j,k)
				if (GetAchievementRewardTitle(id)) then
					d("##="..id.." "..GetAchievementLink(id).." <"..GetAchievementNameFromLink(GetAchievementLink(id)).."> "..select(2, GetAchievementRewardTitle(id)))
				end
			end
		end
	end
end