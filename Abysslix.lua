--[[
================================================================================
   █████╗ ██████╗ ██╗   ██╗███████╗███████╗██╗     ██╗██╗  ██╗
  ██╔══██╗██╔══██╗╚██╗ ██╔╝██╔════╝██╔════╝██║     ██║╚██╗██╔╝
  ███████║██████╔╝ ╚████╔╝ ███████╗███████╗██║     ██║ ╚███╔╝
  ██╔══██║██╔══██╗  ╚██╔╝  ╚════██║╚════██║██║     ██║ ██╔██╗
  ██║  ██║██████╔╝   ██║   ███████║███████║███████╗██║██╔╝ ██╗
  ╚═╝  ╚═╝╚═════╝    ╚═╝   ╚══════╝╚══════╝╚══════╝╚═╝╚═╝  ╚═╝
                              Abysslixhub
                         ── Blox Fruits Script ──
================================================================================

  MỤC LỤC / TABLE OF CONTENTS
  ─────────────────────────────────────────────────────────────────────────────
  § 1   Dịch vụ & Đối tượng      Services / Player / Character
  § 2   Kiểm tra Executor        Executor whitelist check
  § 3   Trạng thái & Hằng số     Global state & constants
  § 4   Dữ liệu tĩnh             Static data tables
  § 5   Tiện ích                 Utilities
  § 6   Di chuyển                Movement   (Tween / SafeMove / BKP)
  § 7   Chiến đấu                Combat     (Attack / Haki / Equip)
  § 8   Truy vấn dữ liệu game    Game data  (Level / Boss / Material)
  § 9   ESP                      Visual overlays
  § 10  Khung giao diện          UI framework (Library / Theme / Tabs)
  § 11  Tab · Thông Tin          Info
  § 12  Tab · Cày Cấp            Main farming
  § 13  Tab · Sự Kiện            Sea events
  § 14  Tab · Vật Phẩm           Items & swords
  § 15  Tab · Cài Đặt            Settings
  § 16  Tab · Webhook            Webhook / Job-ID
  § 17  Tab · Chỉ Số             Stats
  § 18  Tab · Người Chơi         Player utilities
  § 19  Tab · Dịch Chuyển        Teleport
  § 20  Tab · Giả Mạo            Fake / Visual
  § 21  Tab · Trái Ác Quỷ        Devil fruits
  § 22  Tab · Đột Kích           Raid
  § 23  Tab · Chủng Tộc          Race
  § 24  Tab · Cửa Hàng           Shop
  § 25  Tab · Khác               Misc
  § 26  Tính năng mở rộng        Extra features
  ─────────────────────────────────────────────────────────────────────────────
================================================================================
]]

-- ══════════════════════════════════════════════════════════════════════════════
-- §1 · DỊCH VỤ & ĐỐI TƯỢNG
-- ══════════════════════════════════════════════════════════════════════════════

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local HttpService       = game:GetService("HttpService")
local TeleportService   = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser       = game:GetService("VirtualUser")
local Lighting          = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")

local Player     = Players.LocalPlayer
local PlayerGui  = Player:WaitForChild("PlayerGui", 5)

local Character        = Player.Character or Player.CharacterAdded:Wait()
local Humanoid         = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- ══════════════════════════════════════════════════════════════════════════════
-- §2 · KIỂM TRA EXECUTOR
-- ══════════════════════════════════════════════════════════════════════════════

local SUPPORTED_EXECUTORS = {
    "Bunni", "FluxusZ", "Delta", "Arceus", "Xeno", "Swift", "Awp",
    "Volcano", "Argon", "Macsploit", "Potassium", "CodeX", "Velocity",
    "Romix", "Neutron",
}

local executor = (getexecutorname and getexecutorname())
    or (identifyexecutor and identifyexecutor())

if executor then
    local isSupported = false
    for _, name in ipairs(SUPPORTED_EXECUTORS) do
        if string.find(executor, name) then
            isSupported = true
            break
        end
    end

    if isSupported then
        print("ok")
    else
        Player:Kick("Please use Delta Exploit or PC use volcano or Exploit paid!")
    end
end

-- ══════════════════════════════════════════════════════════════════════════════
-- §3 · TRẠNG THÁI & HẰNG SỐ
-- ══════════════════════════════════════════════════════════════════════════════

-- Cờ biển: bật hết để mọi tính năng hoạt động
Sea1 = true
Sea2 = true
Sea3 = true

Number     = math.random(1, 1000000)
Type       = 1
TweenSpeed = 600

-- Tốc độ tối đa server Blox Fruits chấp nhận (studs/giây).
-- Vượt quá thì server giật player về vị trí cũ.
local SERVER_MAX_SPEED = 120  -- studs/giây, an toàn cho server
local STEP_SIZE        = 60   -- studs mỗi bước (120 studs/s × 0.5s wait)
local STEP_WAIT        = 0.5  -- giây chờ giữa mỗi bước

-- ══════════════════════════════════════════════════════════════════════════════
-- §4 · DỮ LIỆU TĨNH
-- ══════════════════════════════════════════════════════════════════════════════

-- ── 4.1 Danh sách quái theo biển ─────────────────────────────────────────────
if Sea1 then
    tableMon = {
        "Bandit", "Monkey", "Gorilla", "Pirate", "Brute",
        "Desert Bandit", "Desert Officer", "Snow Bandit", "Snowman",
        "Chief Petty Officer", "Sky Bandit", "Dark Master",
        "Prisoner", "Dangerous Prisoner", "Toga Warrior", "Gladiator",
        "Military Soldier", "Military Spy", "Fishman Warrior", "Fishman Commando",
        "God's Guard", "Shanda", "Royal Squad", "Royal Soldier",
        "Galley Pirate", "Galley Captain",
    }
elseif Sea2 then
    tableMon = {
        "Raider", "Mercenary", "Swan Pirate", "Factory Staff",
        "Marine Lieutenant", "Marine Captain", "Zombie", "Vampire",
        "Snow Trooper", "Winter Warrior", "Lab Subordinate", "Horned Warrior",
        "Magma Ninja", "Lava Pirate", "Ship Deckhand", "Ship Engineer",
        "Ship Steward", "Ship Officer", "Arctic Warrior", "Snow Lurker",
        "Sea Soldier", "Water Fighter",
    }
elseif Sea3 then
    tableMon = {
        "Pirate Millionaire", "Dragon Crew Warrior", "Dragon Crew Archer",
        "Hydra Enforcer", "Venomous Assailant", "Marine Commodore",
        "Marine Rear Admiral", "Fishman Raider", "Fishman Captain",
        "Forest Pirate", "Mythological Pirate", "Jungle Pirate", "Musketeer Pirate",
        "Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy",
        "Peanut Scout", "Peanut President", "Ice Cream Chef", "Ice Cream Commander",
        "Cookie Crafter", "Cake Guard", "Baking Staff", "Head Baker",
        "Cocoa Warrior", "Chocolate Bar Battler", "Sweet Thief", "Candy Rebel",
        "Candy Pirate", "Snow Demon", "Isle Outlaw", "Island Boy",
        "Sun-kissed Warrior", "Isle Champion", "Serpent Hunter", "Skull Slayer",
    }
end

-- ── 4.2 Danh sách khu vực theo biển ──────────────────────────────────────────
if Sea1 then
    AreaList = {
        "Jungle", "Buggy", "Desert", "Snow", "Marine", "Sky",
        "Prison", "Colosseum", "Magma", "Fishman", "Sky Island", "Fountain",
    }
elseif Sea2 then
    AreaList = {
        "Area 1", "Area 2", "Zombie", "Marine", "Snow Mountain",
        "Ice fire", "Ship", "Frost", "Forgotten",
    }
elseif Sea3 then
    AreaList = {
        "Pirate Port", "Amazon", "Marine Tree", "Deep Forest", "Haunted Castle",
        "Nut Island", "Ice Cream Island", "Cake Island", "Choco Island",
        "Candy Island", "Tiki Outpost",
    }
end

-- ── 4.3 Danh sách trùm theo biển ─────────────────────────────────────────────
if Sea1 then
    tableBoss = {
        "The Gorilla King", "Bobby", "Yeti", "Mob Leader", "Vice Admiral",
        "Warden", "Chief Warden", "Swan", "Magma Admiral", "Fishman Lord",
        "Wysper", "Thunder God", "Cyborg", "Saber Expert",
    }
elseif Sea2 then
    tableBoss = {
        "Diamond", "Jeremy", "Fajita", "Don Swan", "Smoke Admiral",
        "Cursed Captain", "Darkbeard", "Order", "Awakened Ice Admiral", "Tide Keeper",
    }
elseif Sea3 then
    tableBoss = {
        "Stone", "Hydra Leader", "Kilo Admiral", "Captain Elephant",
        "Beautiful Pirate", "rip_indra True Form", "Longma", "Soul Reaper", "Cake Queen",
    }
end

-- ── 4.4 Danh sách nguyên liệu theo biển ──────────────────────────────────────
if Sea1 then
    MaterialList = { "Scrap Metal", "Leather", "Angel Wings", "Magma Ore", "Fish Tail" }
elseif Sea2 then
    MaterialList = {
        "Scrap Metal", "Leather", "Radioactive Material", "Mystic Droplet",
        "Magma Ore", "Vampire Fang",
    }
elseif Sea3 then
    MaterialList = {
        "Scrap Metal", "Leather", "Demonic Wisp", "Conjured Cocoa", "Dragon Scale",
        "Gunpowder", "Fish Tail", "Mini Tusk", "Hydra Enforcer", "Venomous Assailant",
    }
end

-- ── 4.5 Danh sách đảo dịch chuyển theo biển ──────────────────────────────────
if Sea1 then
    IslandList = {
        "WindMill", "Marine", "Middle Town", "Jungle", "Pirate Village",
        "Desert", "Snow Island", "MarineFord", "Colosseum",
        "Sky Island 1", "Sky Island 2", "Sky Island 3", "Prison",
        "Magma Village", "Under Water Island", "Fountain City", "Shank Room", "Mob Island",
    }
elseif Sea2 then
    IslandList = {
        "The Cafe", "Frist Spot", "Dark Area", "Flamingo Mansion", "Flamingo Room",
        "Green Zone", "Factory", "Colossuim", "Zombie Island", "Two Snow Mountain",
        "Punk Hazard", "Cursed Ship", "Ice Castle", "Forgotten Island",
        "Ussop Island", "Mini Sky Island",
    }
elseif Sea3 then
    IslandList = {
        "Mansion", "Port Town", "Great Tree", "Castle On The Sea", "MiniSky",
        "Hydra Island", "Floating Turtle", "Haunted Castle", "Ice Cream Island",
        "Peanut Island", "Cake Island", "Cocoa Island", "Candy Island", "Tiki Outpost",
    }
end

-- ── 4.6 Danh sách boss sự kiện (tính năng mở rộng) ───────────────────────────
local _bossPainList = {}
if Sea1 then
    _bossPainList = {
        "The Gorilla King", "Bobby", "Yeti", "Mob Leader", "Vice Admiral",
        "Warden", "Chief Warden", "Swan", "Magma Admiral", "Fishman Lord",
        "Wysper", "Thunder God", "Cyborg", "Saber Expert",
    }
elseif Sea2 then
    _bossPainList = {
        "Diamond", "Jeremy", "Fajita", "Don Swan", "Smoke Admiral",
        "Cursed Captain", "Darkbeard", "Order", "Awakened Ice Admiral", "Tide Keeper",
    }
elseif Sea3 then
    _bossPainList = {
        "Stone", "Island Empress", "Hydra Leader", "Kilo Admiral", "Captain Elephant",
        "Beautiful Pirate", "rip_indra True Form", "Longma", "Soul Reaper",
        "Cake Queen", "Tyrant of the Skies",
    }
end
-- ── 4.7 Chip đột kích ────────────────────────────────────────────────────────
RAID_CHIPS = {
    "Flame", "Ice", "Quake", "Light", "Dark", "Spider",
    "Rumble", "Magma", "Buddha", "Sand", "Phoenix", "Dough",
}

-- ── 4.8 Danh sách thuyền ─────────────────────────────────────────────────────
BOAT_NAMES = {
    "Beast Hunter", "Sleigh", "Miracle", "The Sentinel", "Guardian", "Lantern",
    "Dinghy", "PirateSloop", "PirateBrigade", "PirateGrandBrigade",
    "MarineGrandBrigade", "MarineBrigade", "MarineSloop",
}

-- Góc quay thuyền khi dò tìm đảo
BOAT_TURN_ANGLES = { 80, -50, -80, 50 }

-- ── 4.9 Câu cá ───────────────────────────────────────────────────────────────
FISHING_BAITS = {
    "Basic Bait", "Kelp Bait", "Good Bait", "Abyssal Bait",
    "Frozen Bait", "Epic Bait", "Carnivore Bait",
}

FISHING_RODS = { "Fishing Rod", "Gold Rod", "Shark Rod", "Shell Rod", "Treasure Rod" }

-- ── 4.10 Code đổi thưởng (gộp 2 danh sách cũ, đã loại trùng) ─────────────────
REDEEM_CODES = {
    "KITT_RESET", "Sub2UncleKizaru", "SUB2GAMERROBOT_RESET1", "Sub2Fer999",
    "Enyu_is_Pro", "JCWK", "StarcodeHEO", "MagicBus", "KittGaming",
    "Sub2CaptainMaui", "Sub2OfficalNoobie", "TheGreatAce", "Sub2NoobMaster123",
    "Sub2Daigrock", "Axiore", "StrawHatMaine", "TantaiGaming", "Bluxxy",
    "SUB2GAMERROBOT_EXP1", "Chandler", "NOMOREHACK", "BANEXPLOIT", "WildDares",
    "BossBuild", "GetPranked", "EARN_FRUITS", "FIGHT4FRUIT", "NOEXPLOITER",
    "NOOB2ADMIN", "CODESLIDE", "ADMINHACKED", "ADMINDARES", "fruitconcepts",
    "krazydares", "TRIPLEABUSE", "SEATROLLING", "24NOADMIN", "REWARDFUN",
    "NEWTROLL", "fudd10_v2", "Fudd10", "Bignews", "SECRET_ADMIN",
    "kittgaming", "Magicbus", "Starcodeheo", "SUB2OFFICIALNOOBIE", "AXIORE",
    "BIGNEWS", "BLUXXY", "CHANDLER", "ENYU_IS_PRO", "FUDD10", "FUDD10_V2",
    "KITTGAMING", "MAGICBUS", "STARCODEHEO", "STRAWHATMAINE", "SUB2CAPTAINMAUI",
    "SUB2DAIGROCK", "SUB2FER999", "SUB2NOOBMASTER123", "SUB2UNCLEKIZARU",
    "TANTAIGAMING", "THEGREATACE",
}

-- ── 4.11 Âm thanh khi đánh ───────────────────────────────────────────────────
HIT_SOUNDS = {
    "rbxassetid://5221806718",
    "rbxassetid://5221806728",
    "rbxassetid://5221806736",
    "rbxassetid://341336274",
    "rbxassetid://5221806751",
}

-- ── 4.12 Điểm tuần tra Tyrant of the Skies ───────────────────────────────────
TYRANT_PATROL = {
    CFrame.new(-16250.24, 158.17, 1313.02),
    CFrame.new(-16297.06, 159.32, 1317.22),
    CFrame.new(-16335.10, 159.33, 1324.89),
    CFrame.new(-16288.61, 158.17, 1470.37),
    CFrame.new(-16258.00, 156.76, 1461.40),
    CFrame.new(-16245.41, 158.44, 1463.37),
    CFrame.new(-16212.47, 158.17, 1466.34),
}

-- ── 4.13 Vị trí phá cây ở đảo Hydra ──────────────────────────────────────────
HYDRA_TREE_POS = {
    CFrame.new(5288.61962890625,  1005.4000244140625, 392.43011474609375),
    CFrame.new(5343.39453125,     1004.1998901367188, 361.0687561035156),
    CFrame.new(5235.78564453125,  1004.1998901367188, 431.4530944824219),
    CFrame.new(5321.30615234375,  1004.1998901367188, 440.8951416015625),
    CFrame.new(5258.96484375,     1004.1998901367188, 345.5052490234375),
}

-- ── 4.14 User ID cần tránh (chống band) ──────────────────────────────────────
ANTIBAN_USER_IDS = { 17884881, 120173604, 912348 }

-- ── 4.15 Nhóm đảo dùng cho tính năng dò tìm đảo ──────────────────────────────
SEA_ISLAND_GROUPS = {
    Prehistoric = {
        "ShipwreckIsland", "SandIsland", "TreeIsland", "TinyIsland",
        "MysticIsland", "KitsuneIsland", "FrozenDimension",
    },
    Mirage = {
        "ShipwreckIsland", "SandIsland", "TreeIsland", "TinyIsland",
        "PrehistoricIsland", "KitsuneIsland", "FrozenDimension",
    },
    Frozen = {
        "ShipwreckIsland", "SandIsland", "TreeIsland", "TinyIsland",
        "MysticIsland", "KitsuneIsland", "PrehistoricIsland",
    },
}

-- ══════════════════════════════════════════════════════════════════════════════
-- §5 · TIỆN ÍCH
-- ══════════════════════════════════════════════════════════════════════════════

-- Làm tròn số (dùng chung cho mọi ESP)
local function round(value)
    return math.floor(tonumber(value) + 0.5)
end

function isnil(value)
    return value == nil
end
-- ══════════════════════════════════════════════════════════════════════════════
-- §6 · DI CHUYỂN
-- ══════════════════════════════════════════════════════════════════════════════

-- Độ lệch vị trí khi đứng cạnh quái (được gán lại liên tục bởi vòng lặp dưới)
spawn(function()
    while wait() do
        if Type == 1 then
            Pos = CFrame.new(0, 30, 0)
        end
    end
end)

spawn(function()
    while wait() do
        Type = 1
    end
end)

-- Bay mượt tới CFrame mục tiêu (không chặn luồng hiện tại)
function Tween2(targetCF)
    if not targetCF then return end
    local distance = (targetCF.Position - Player.Character.HumanoidRootPart.Position).Magnitude
    local speed    = 350
    local info     = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
    local tween    = TweenService:Create(Player.Character.HumanoidRootPart, info, {
        ["CFrame"] = targetCF,
    })
    tween:Play()
    if _G.StopTween2 then
        tween:Cancel()
    end
    _G.Clip2 = true
    wait(distance / speed)
    _G.Clip2 = false
end

-- Dịch chuyển tức thời tới CFrame (gửi 2 lần để server chấp nhận)
function BKP(targetCF)
    Player.Character.HumanoidRootPart.CFrame = targetCF
    task.wait()
    Player.Character.HumanoidRootPart.CFrame = targetCF
end

-- SafeMove: di chuyển từng bước nhỏ để server không reject
-- Mỗi bước ~60 studs, chờ 0.5s để server sync trước khi bước tiếp
local function SafeMove(targetCF, checkStop)
    if not Player.Character then return end
    local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetPos = targetCF.Position
    while true do
        if checkStop and checkStop() then break end
        local curPos    = hrp.Position
        local remaining = (targetPos - curPos).Magnitude
        if remaining < 8 then break end

        -- Tính điểm đến của bước này
        local dir      = (targetPos - curPos).Unit
        local stepDist = math.min(remaining, STEP_SIZE)
        local nextPos  = curPos + dir * stepDist

        -- Giữ nguyên rotation của CFrame đích, chỉ thay position
        local nextCF
        if remaining <= STEP_SIZE then
            nextCF = targetCF  -- bước cuối giữ đúng CFrame
        else
            nextCF = CFrame.new(nextPos)
        end

        pcall(function()
            hrp.CFrame = nextCF
        end)
        task.wait(STEP_WAIT)
    end
end

-- Tween không blocking: dùng SafeMove trong coroutine riêng.
-- Khi đích thay đổi thì coroutine cũ bị hủy.
local _tweenThread = nil

function Tween(targetCF)
    if not targetCF then return end
    if _tweenThread then
        pcall(function() task.cancel(_tweenThread) end)
        _tweenThread = nil
    end
    _tweenThread = task.spawn(function()
        SafeMove(targetCF, function()
            return _tweenThread == nil
        end)
        _tweenThread = nil
    end)
end

-- TweenBlock: SafeMove blocking, chờ đến nơi rồi mới return
function TweenBlock(targetCF)
    if not targetCF then return end
    if _tweenThread then
        pcall(function() task.cancel(_tweenThread) end)
        _tweenThread = nil
    end
    _G.Clip2 = true
    pcall(function()
        SafeMove(targetCF, function()
            return _G.StopTween
        end)
    end)
    _G.Clip2 = false
end

-- Dịch chuyển đường dài (dùng requestEntrance khi khoảng cách >= 2000)
function to(targetCF)
    pcall(function()
        if (targetCF.Position - Player.Character.HumanoidRootPart.Position).Magnitude >= 2000
            and (not Auto_Raid and Player.Character.Humanoid.Health > 0)
        then
            if NameMon ~= "FishmanQuest" then
                if Mon ~= "God's Guard" then
                    if NameMon ~= "SkyExp1Quest" then
                        if NameMon ~= "ShipQuest1" then
                            if NameMon ~= "ShipQuest2" then
                                if NameMon ~= "FrostQuest" then
                                    repeat
                                        wait(_G.Fast_Delay)
                                        Player.Character.HumanoidRootPart.CFrame = targetCF
                                        wait(0.05)
                                        Player.Character.Head:Destroy()
                                        Player.Character.HumanoidRootPart.CFrame = targetCF
                                    until (targetCF.Position - Player.Character.HumanoidRootPart.Position).Magnitude < 2500
                                        and Player.Character.Humanoid.Health > 0
                                    wait()
                                else
                                    Tween(Player.Character.HumanoidRootPart.CFrame)
                                    wait()
                                    ReplicatedStorage.Remotes.CommF_:InvokeServer(
                                        "requestEntrance",
                                        Vector3.new(-6508.5581054688, 89.034996032715, -132.83953857422)
                                    )
                                end
                            else
                                Tween(Player.Character.HumanoidRootPart.CFrame)
                                wait()
                                ReplicatedStorage.Remotes.CommF_:InvokeServer(
                                    "requestEntrance",
                                    Vector3.new(923.21252441406, 126.9760055542, 32852.83203125)
                                )
                            end
                        else
                            Tween(Player.Character.HumanoidRootPart.CFrame)
                            wait()
                            ReplicatedStorage.Remotes.CommF_:InvokeServer(
                                "requestEntrance",
                                Vector3.new(923.21252441406, 126.9760055542, 32852.83203125)
                            )
                        end
                    else
                        Tween(Player.Character.HumanoidRootPart.CFrame)
                        wait()
                        ReplicatedStorage.Remotes.CommF_:InvokeServer(
                            "requestEntrance",
                            Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047)
                        )
                    end
                else
                    Tween(Player.Character.HumanoidRootPart.CFrame)
                    wait()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer(
                        "requestEntrance",
                        Vector3.new(-4607.82275, 872.54248, -1667.55688)
                    )
                end
            else
                Tween(Player.Character.HumanoidRootPart.CFrame)
                wait()
                ReplicatedStorage.Remotes.CommF_:InvokeServer(
                    "requestEntrance",
                    Vector3.new(61163.8515625, 11.6796875, 1819.7841796875)
                )
            end
        end
    end)
end
