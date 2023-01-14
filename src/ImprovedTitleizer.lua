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
			{ID=92,Rank=1}, --Volunteer --Alliance War Volunteer
			{ID=93,Rank=2}, --Recruit --Alliance War Recruit
			{ID=94,Rank=3}, --Tyro --Alliance War Tyro
			{ID=95,Rank=4}, --Legionary --Alliance War Legionary
			{ID=96,Rank=5}, --Veteran --Alliance War Veteran
			{ID=97,Rank=6}, --Corporal --Alliance War Corporal
			{ID=98,Rank=7}, --Sergeant --Alliance War Sergeant
			{ID=706,Rank=8}, --First Sergeant --Alliance War First Sergeant
			{ID=99,Rank=9}, --Lieutenant --Alliance War Lieutenant
			{ID=100,Rank=10}, --Captain --Alliance War Captain
			{ID=101,Rank=11}, --Major --Alliance War Major
			{ID=102,Rank=12}, --Centurion --Alliance War Centurion
			{ID=103,Rank=13}, --Colonel --Alliance War Colonel
			{ID=104,Rank=14}, --Tribune --Alliance War Tribune
			{ID=105,Rank=15}, --Brigadier --Alliance War Brigadier
			{ID=106,Rank=16}, --Prefect --Alliance War Prefect
			{ID=107,Rank=17}, --Praetorian --Alliance War Praetorian
			{ID=108,Rank=18}, --Palatine --Alliance War Palatine
			{ID=109,Rank=19}, --August Palatine --Alliance War August Palatine
			{ID=110,Rank=20}, --Legate --Alliance War Legate
			{ID=111,Rank=21}, --General --Alliance War General
			{ID=112,Rank=22}, --Warlord --Alliance War Warlord
			{ID=113,Rank=23}, --Grand Warlord --Alliance War Grand Warlord
			{ID=114,Rank=24}, --Overlord --Alliance War Overlord
			{ID=705,Rank=25}, --Grand Overlord --Alliance War Grand Overlord
		},
	},
	{
		Name="Arena",
		Entries=
		{
			{ID=992}, --Dragonstar Arena Champion --Dragonstar Arena Champion
			{ID=1140}, --Boethiah's Scythe --Dragonstar Arena Conqueror
			{ID=1304}, --Maelstrom Arena Champion --Maelstrom Arena Champion
			{ID=1305}, --Stormproof --Maelstrom Arena Conqueror
			{ID=1330}, --The Flawless Conqueror --Maelstrom Arena: Perfect Run
			{ID=2362}, --Blackrose Condemner --Blackrose Prison Vanquisher
			{ID=2363}, --Blackrose Executioner --Blackrose Prison Conqueror
			{ID=2368}, --The Unchained --God of the Gauntlet
			{ID=2908}, --Spiritblood Champion --Vateshran Hollows Conqueror
			{ID=2912}, --Spirit Slayer --The Vateshran's Chosen
			{ID=2913}, --of the Undying Song --Hero of the Unending Song
		}
	},
	{
		Name="Battlegrounds",
		Entries=
		{
			{ID=1895}, --Bloodletter --Pit Hero
			{ID=1898}, --Relic Hunter --Grand Relic Hunter
			{ID=1901}, --Relic Guardian --Grand Relic Guardian
			{ID=1904}, --Standard-Bearer --Grand Standard-Bearer
			{ID=1910}, --Conquering Hero --Conquering Hero
			{ID=1913}, --Grand Champion --Grand Champion
			{ID=1919}, --Relic Runner --Triple Threat
			{ID=1954}, --Chaos Guardian --Chaos Guardian
			{ID=1955}, --Chaos Champion --Chaos Champion

		}
	},
	{
		Name="Dungeon",
		Entries=
		{
			{ID=1159}, --Deadlands Adept --Deadlands Savvy
			{ID=1538}, --Hist-Shadow --Shadows of the Hist Delver
			{ID=1691}, --Bane of Beastmen --Bloodroot Forge Conqueror
			{ID=1696}, --Forge Breaker --Tempered Tantrum
			{ID=1699}, --Jarl Maker --Falkreath Hold Conqueror
			{ID=1704}, --Thane of Falkreath --Taking the Bull by the Horns
			{ID=1960}, --Blackmarrow's Bane --Fang Lair Conqueror
			{ID=1965}, --Dovahkriid --Let Bygones Be Bygones
			{ID=1976}, --Peak Scaler --Scalecaller Peak Conqueror
			{ID=1981}, --Plague of Peryite --Breaker of Spells
			{ID=2153}, --Silver Knight --Moon Hunter Keep Conqueror
			{ID=2154}, --Alpha Predator --The Alpha Predator
			{ID=2163}, --Huntmaster --March of Sacrifices Conqueror
			{ID=2164}, --Hircine's Champion --Hircine's Champion
			{ID=2266}, --Frozen Treasure Seeker --Frostvault Challenger
			{ID=2275}, --Purified Devastator --Depths of Malatar Challenger
			{ID=2421}, --Chevalier --Moongrave Fane Challenger
			{ID=2427}, --Z'en's Redeemer --Selene's Savior
			{ID=2430}, --Guardian of the Green --Lair of Maarselok Challenger
			{ID=2541}, --Witch Hunter --Cold-Blooded Killer
			{ID=2546}, --Storm Foe --No Rest for the Wicked
			{ID=2551}, --Sanctifier --Skull Smasher
			{ID=2555}, --Bonecaller's Bane --In Defiance of Death
			{ID=2701}, --True Genius --True Genius
			{ID=2706}, --The Inedible --Thorn Remover
			{ID=2710}, --Bane of Thorns --Bane of Thorns
			{ID=2751}, --Dark Delver --Companion of Lyris Titanborn
			{ID=2755}, --Pinnacle of Evolution --Triple Checked
			{ID=2833}, --Flamechaser --Snuffed Out
			{ID=2838}, --Ardent Bibliophile --Ardent Bibliophile
			{ID=2843}, --Spark of Vengeance --Schemes Disrupted
			{ID=2847}, --Subterranean Smasher --Subterranean Smasher
			{ID=3018}, --Seeker of Artifacts --Prior Offenses
			{ID=3023}, --of the Silver Rose --Bastion Breaker
			{ID=3028}, --Incarnate --Unshaken
			{ID=3032}, --The Dreaded --Battlespire's Best
			{ID=3111}, --Coral Caretaker --Land, Air, and Sea Supremacy
			{ID=3120}, --Privateer --Zero Regrets
			{ID=3153}, --Gryphon Handler --Superior Pedigree
			{ID=3154}, --Tide Turner --Shove Off
			{ID=3224}, --Shipwright --Sans Spirit Support
			{ID=3226}, --Aerie Ascender --Tentacless Triumph
			{ID=3377}, --Earthen Root Avenger --Earthen Root Avenger
			{ID=3381}, --Invaders' Bane --Invaders' Bane
			{ID=3396}, --Breathless --Breathless
			{ID=3400}, --Fist of Tava --Fist of Tava
			{ID=3525}, --Earthen Root Champion --Earthen Root Enclave Champion
			{ID=3526}, --Graven Deep Champion --Graven Deep Champion
		}
	},
	{
		Name="Holiday",
		Entries={
			{ID=1546}, --Sun's Dusk Reaper --An Unsparing Harvest
			{ID=1677}, --Magnanimous --Glory of Magnus
			{ID=1716}, --Lord of Misrule --<<player{Lord/Lady}>> of Misrule
			{ID=1723}, --Royal Jester --Royal Jester
			{ID=1892}, --Star-Made Knight --Star-Made Knight
			{ID=2453}, --Tin Soldier --The Upper Crust
			{ID=2458}, --Empieror --Messy Business
			{ID=2587}, --Witch --Wicked Writ Witch
		}
	},
	{
		Name="Tales of Tribute",
		Entries={
			{ID=3349,Rank=1}, --Roister's Club Initiate --Roister's Club Initiate
			{ID=3350,Rank=2}, --Roister's Club Trainee --Roister's Club Trainee
			{ID=3351,Rank=3}, --Roister's Club Novice --Roister's Club Novice
			{ID=3352,Rank=4}, --Roister's Club Regular --Roister's Club Regular
			{ID=3353,Rank=5}, --Roister's Club Adept --Roister's Club Adept
			{ID=3354,Rank=6}, --Roister's Club Expert --Roister's Club Expert
			{ID=3355,Rank=7}, --Roister's Club Veteran --Roister's Club Veteran
			{ID=3356,Rank=8}, --Roister's Club Master --Roister's Club Master
		}
	},
	{
		Name="Skyshard Hunter",
		Entries={
			{ID=2516}, --Craglorn Skyshard Hunter
			{ID=2513}, --Dominion Skyshard Hunter
			{ID=2514}, --Covenant Skyshard Hunter
			{ID=2515}, --Pact Skyshard Hunter
			{ID=2517}, --Cyrodiil Skyshard Hunter
		}
	},
	{
		Name="Savior",
		Entries={
			{ID=587}, --Savior of Nirn --Anchors Away
			{ID=1868}, --Savior of Morrowind --Savior of Morrowind
			{ID=2193}, --Savior of Summerset --Savior of Summerset
			{ID=2509}, --Savior of Elsweyr --Savior of Elsweyr
			{ID=2712}, --Savior of Western Skyrim --Savior of Western Skyrim
			{ID=3047}, --Savior of Blackwood --Savior of Blackwood
			{ID=3271}, --Savior of High Isle --Savior of High Isle
			{ID=3512}, --Sower's Savior --Firesong Extinguisher
		}
	},
	{
		Name="Master",
		Entries={
			{ID=1383}, --Master Thief -- A Cutpurse Above ",
			{ID=2620}, --Master Grappler -- Grappling Bow Pathfinder ",
			{ID=2805}, --Master Historian -- Master Antiquarian ",
			{ID=494}, --Master Angler -- Master Fisher ",
			{ID=702}, --Master Wizard -- Arch-Mage ",
		}
	},
	{
		Name="Trials",
		Entries={
			{ID=1391}, --Dro-m'Athra Destroyer --Maw of Lorkhaj: Moons' Champion
			{ID=1462}, --Ophidian Overlord --Sanctum Ophidia Conqueror
			{ID=1474}, --Shehai Shatterer --Hel Ra Citadel Conqueror
			{ID=1503}, --Mageslayer --Aetherian Archive Conqueror
			{ID=1808}, --Clockwork Confounder --Halls of Fabrication Completed
			{ID=1810}, --Divayth Fyr's Coadjutor --Halls of Fabrication Conqueror
			{ID=1836}, --The Dynamo --Dynamo
			{ID=1837}, --Disassembly General --Stress Tested
			{ID=1838}, --Tick-Tock Tormentor --Like Clockwork
			{ID=2075}, --Immortal Redeemer --Asylum Sanctorium Redeemer
			{ID=2076}, --Orderly --Asylum Sanctorium Completed
			{ID=2077}, --Assistant Alienist --Asylum Sanctorium Conqueror
			{ID=2079}, --Voice of Reason --Asylum Sanctorium Vanquisher
			{ID=2087}, --Saintly Savior --Perfect Purification
			{ID=2131}, --Cloudrest Hero --Cloudrest Completed
			{ID=2133}, --Shadow Breaker --Cloudrest Conqueror
			{ID=2136}, --Bringer of Light --Cloudrest Vanquisher
			{ID=2139}, --Gryphon Heart --The Path to Alaxon
			{ID=2140}, --Welkynar Liberator --Cloudrest Savior
			{ID=2433}, --Sunspire Ascendant --Sunspire Completed
			{ID=2435}, --Sunspire Saint --Sunspire Conqueror
			{ID=2466}, --Extinguisher of Flames --Sunspire Vanquisher
			{ID=2467}, --Godslayer --Godslayer of Sunspire
			{ID=2468}, --Hand of Alkosh --Sunspire Dragonbreak
			{ID=2732}, --Kyne's Chosen --Kyne's Aegis Completed
			{ID=2734}, --Kyne's Will --Kyne's Aegis Conqueror
			{ID=2739}, --Shield of the North --Kyne's Aegis Vanquisher
			{ID=2740}, --Kyne's Wrath --Stainless Siege-breaker
			{ID=2746}, --Dawnbringer --Kyne's Deliverance
			{ID=2985}, --Defender of Rockgrove --Rockgrove Completed
			{ID=2987}, --Ca-Uxith Warrior --Rockgrove Conqueror
			{ID=3003}, --Planesbreaker --Soul Savior
			{ID=3004}, --Daedric Bane --Xalvakka's Bane
			{ID=3007}, --Xalvakka's Scourge --Rockgrove Vanquisher
			{ID=3242}, --Dreadsails' Scourge --Dreadsail Reef Vanquisher
			{ID=3244}, --Seaborne Slayer --Dreadsail Reef Conqueror
			{ID=3248}, --Soul of the Squall --Fleet Queen's Foil
			{ID=3249}, --Swashbuckler Supreme --Swashbuckler Supreme
			{ID=3252}, --Hurricane Herald --Master Marine
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
--Usage: local achievementId = GetAchievementId(categoryIndex, subcategoryIndex, achievementIndex)
local GetAchievementInfo                 = GetAchievementInfo
--Usage local name, description, points, icon, completed, date, time = GetAchievementInfo(achievementId)


local GetTitle                           = GetTitle -- I want original titles
--Usage: local strTitle GetTitle(achievementId)

local function InitializeTitles()
	--local logger = LibDebugLogger("ImprovedTitleizer")

	local function CheckAchievementsInLine(id, categoryId, categoryName, subCategory, subCategoryName)
		--Go through every achievement looking for if a title exists for it.
		local firstId = GetFirstAchievementInLine(id)
		id = firstId > 0 and firstId or id
		while id > 0 do
			local hasTitle, title = GetAchievementRewardTitle(id)
			if hasTitle then
				local achieveName = GetAchievementNameFromLink(GetAchievementLink(id))
				local name, description, points, icon, completed, date, time = GetAchievementInfo(id)
				local playerHasTitle = false
				local playerTitleIndex = -1
				for j=1,GetNumTitles() do
					if title == GetTitle(j) then
						playerHasTitle = true
						playerTitleIndex = j
						break
					end
				end
				table.insert(AllTitles,1,{AchievementID=id,TitleID=playerTitleIndex,Title=title,CategoryID=categoryId, CategoryName=categoryName,SubCategoryID=subCategory,SubCategoryName=subCategoryName,HasTitle=playerHasTitle,AchievementName=achieveName,AchievementDescription=description},1);
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
	local debug = false
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
			if(vTitle.HasTitle) then
				local titlePlaced = false
				local toolTip = vTitle.AchievementName.."\n"..vTitle.CategoryName
				if debug==true then
					toolTip = toolTip.."\n"..vTitle.TitleID
				end
				for k, vCategory in pairs(AchievmentIdsCategories) do
					for j,q in pairs(vCategory.Entries) do
						if vTitle.AchievementID==q.ID then
							table.insert(subMenus[vCategory.Name].Entries,{name=(q.Icon or "")..vTitle.Title, rank=q.Rank or 0, callback=function() SelectTitle(vTitle.TitleID) end,tooltip=toolTip})
							titlePlaced=true
						end
					end
				end
				if(titlePlaced==false) then
					table.insert(menu,{name=vTitle.Title, rank = 0, callback=function() SelectTitle(vTitle.TitleID) end,tooltip=toolTip})
				end
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
	--{TitleID=id, CategoryID=categoryId, CategoryName=categoryName,SubCategoryID=subCategory,SubCategoryName=subCategoryName,HasTitle=hasTitle}
	for i,vTitle in pairs(AllTitles) do
		local output = ""
		output = output..vTitle.TitleID.." "
		output = output.."HasTitle: "..tostring(vTitle.HasTitle).." "
		output = output.."Title: "..vTitle.Title.." "
		output = output.."CategoryID: "..vTitle.CategoryID.." "
		output = output.."CategoryName: "..vTitle.CategoryName.." "
		output = output.."AchievementID: "..vTitle.AchievementID.." "
		output = output.."AchievementName: "..vTitle.AchievementName.." "
		output = output.."AchievementDescription: "..vTitle.AchievementDescription.." "
		d(output)
	end
end