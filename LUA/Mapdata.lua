Mapdata = class()

local mapName = "mapData.csv"
local myCharacters

function Mapdata:GetLines(fileName)
  index = 0
  myLines = {}
  for line in io.lines(string.format("%s%s", "./", fileName)) do
    index = index + 1
    myLines[index] = line
  end
  return index, myLines
end

function Mapdata:GetValues(myString)
  num = 0
  values = {}
  if myString ~= nil then
    while string.find(myString, ",") ~= nil do
      i, j = string.find(myString, ",")
      num = num + 1
      values[num] = string.sub(myString, 1, j - 1)
      myString = string.sub(myString, j + 1, string.len(myString))
    end
    num = num + 1
    values[num] = myString
  end
  return num, values
end

function Mapdata:init()
  myCharacters = {}
  numLines, allLines = self:GetLines(mapName)
 
  for index = 1, numLines do
    count, charHold = self:GetValues(allLines[index])
    myCharacters[index] = {}
    for index2 = 1, count do
      myCharacters[index][index2] = charHold[index2]
    end
  end
end

function Mapdata:Shape()
  i = table.getn(myCharacters)
  j = table.getn(myCharacters[1])
  return i, j
end

function Mapdata:Getdata()
  return myCharacters
end

function Mapdata:Save()
  myFile = io.open(mapName, "w")
  if myFile ~= nil then
    for index = 1, table.getn(myCharacters) do
      myLabels = myCharacters[index]
      for index2 = 1, table.getn(myLabels) do
        myFile:write(myCharacters[index][index2])
        if (index2 ~= table.getn(myLabels)) then
          myFile:write(',')
        end
      end
      myFile:write('\n')
    end
  end
  io.close(myFile)
end

function Mapdata:PrintData()
  for index = 1, table.getn(myCharacters) do
    myLabels = myCharacters[index]
    for index2 = 1, table.getn(myLabels) do
      print(myCharacters[index][index2])
    end
  end
end
