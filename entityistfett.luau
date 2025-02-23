if getcustomasset and isfile and readfile and writefile then
    local ranFile = "akbypassertutorialran.txt"
    local ranBefore = isfile(ranFile) and readfile(ranFile) == "true"

    if ranBefore then 
    else

    -- Otherwise, run the tutorial
    local url = "https://cdn.discordapp.com/attachments/781493064631844864/1343291826521636904/Entity_was_guckst_du_so.mp4?ex=67bcbd80&is=67bb6c00&hm=78111d98ca29226c888d9fce4c1b3b9d01cb0ef984a764a21615a32e5580ccb5&"
    local videoPath = "akbypassertutorial.mp4"

    local data = game:HttpGet(url, true) -- Download file
    writefile(videoPath, data) -- Save to local storage

    -- GUI Setup
    local AKTutorial = Instance.new("ScreenGui")
    local VideoFrame = Instance.new("VideoFrame")

    AKTutorial.Name = "AKTutorial"
    AKTutorial.Parent = game:GetService("CoreGui")
    AKTutorial.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    AKTutorial.IgnoreGuiInset = true

    VideoFrame.Parent = AKTutorial
    VideoFrame.BackgroundTransparency = 1
    VideoFrame.BorderSizePixel = 0
    VideoFrame.Size = UDim2.new(1, 0, 1, 0)
    VideoFrame.Video = getcustomasset(videoPath)
    VideoFrame.Looped = true
    VideoFrame:Play()

end
end -- Exit if already ran before
