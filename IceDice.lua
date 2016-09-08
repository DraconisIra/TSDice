local printIceDice = function(message)
    print("\n[-] IceDice: "..message.."\n")
end
critCount = 0
critFailCount = 0
--rolls a dice and give the result as well as adding the result to the total
local setResult = function(numberOfDiceFace, result, valueToAdd, resultMod, total)
    result = math.random(numberOfDiceFace)
    --printIceDice("result = "..result)
    resultMod = math.floor(result+valueToAdd)
    total = total + resultMod
    --printIceDice("resultMod = "..resultMod)
    if tonumber(result) == tonumber(numberOfDiceFace) then
        resultMod = "[b][color=green]"..resultMod.."[/color][/b]"
        critCount = critCount+1
    elseif tonumber(result) == 1 then
        resultMod = "[b][color=red]"..resultMod.."[/color][/b]"
        critFailCount = critFailCount+1
    end
    --printIceDice("total = "..total)
    return resultMod, total, result
end
-->roll xxdxxxx
--max 75d if x face
--max 70d if xx face

local function compileText(tmpResult,total,valueToAdd,returnMsg)
    local result
    local result2
    local critString = " [Criticals: [color=green][b]"..critCount.."[color=red]/"..critFailCount.."[/b][/color]]"
    local totalCrit =critCount+critFailCount
    local flatAdd = ""

    critCount = 0
    critFailCount = 0

    if valueToAdd ~= 0 then
        flatAdd = "+"..valueToAdd
    end

    result=tmpResult..flatAdd..": ".."[b]"..total.."[/b]"
    result2=result..returnMsg

    if string.len(result2) > 1024 then
        return result..critString
    else
        if totalCrit>0 then
            return result2..critString
        end
        return result2
    end

    return "Im sorry What?"
end


local function diceRoller(message, fromName, clientID, fromID)

    printIceDice("IceDice.diceRoller("..message..", "..fromName..")")

    -- Initialize the pseudo random number generator
    math.randomseed( os.time() )
    math.random(); math.random(); math.random()
    math.randomseed(math.random()*os.time())
    math.random(); math.random(); math.random()

    --finds the position of the d to calculate the numberOfDice and numberOfDiceFace
    local dPosition = string.find(message, "d")

    local modPosition = 0
    local valueToAdd = 0
    if string.find(message,"+") ~= nil then
        if string.find(message,'+',dPosition) == nil then
            modPosition = string.find(message,'-',dPosition)
        else
            modPosition = string.find(message,'+',dPosition)
        end
        printIceDice("modPosition = "..modPosition)
        valueToAdd = string.sub(message, modPosition+1) --finds the vaLue that will be added at the end after the + or -
        for i=1,string.len("valueToAdd") do
            if string.sub(valueToAdd,1,1) == "+" or string.sub(valueToAdd,1,1) == "-" then
                valueToAdd = string.sub(valueToAdd,2)
                --printIceDice("valueToAdd"..i.." = "..valueToAdd)
            end
        end
    else
        --printIceDice("valueToAdd = "..valueToAdd)
    end

    local rollStartPos, rollEndPos = string.find(message, "roll")

    local numberOfDicePosEnd = dPosition-1 --numberOfDice is just before d
    local numberOfDice = string.sub(message, rollEndPos+1, numberOfDicePosEnd) --finds the numberOfDice after roll .If there is anything other than a number it will not work
    for i=1,string.len("numberOfDice") do
        if string.sub(numberOfDice,1,1) == "+" or string.sub(numberOfDice,1,1) == "-" then
            numberOfDice = string.sub(numberOfDice,2)
            printIceDice("numberOfDice"..i.." = "..numberOfDice)
        end
    end
    --numberOfDice = string.sub(numberOfDice, 1)

    if tonumber(numberOfDice) < 0 then
        return "I'm sorry hwat?"
    elseif tonumber(numberOfDice) > 10000 then
        return "[b]no[/b]"
    elseif tonumber(numberOfDice) < 1 then
        return "Total is [b]"..valueToAdd.."[/b] you autist"
    elseif tonumber(numberOfDice) == nil then
        return "ERROR: invalid input"
    end

    --printIceDice("numberOfDice = "..numberOfDice)

    local numberOfDiceFacePos = dPosition+1 --numberOfDiceFace is after d
    local numberOfDiceFace
    if modPosition == 0 then
        numberOfDiceFace = string.sub(message, numberOfDiceFacePos,numberOfDiceFacePos+4)
    else
        numberOfDiceFace = string.sub(message, numberOfDiceFacePos, modPosition-1)
    end
    --printIceDice("numberOfDiceFace = "..numberOfDiceFace)

    local tmpResult = numberOfDice.."d"..numberOfDiceFace
   --[[ if valueToAdd ~= 0 then
        tmpResult = tmpResult.." + "..valueToAdd
    end]]--

    printIceDice("Rolling Dice")

    local total = 0
    local result = 0

    local returnMsg = " [" --start the result of the roll

    if tonumber(numberOfDice) > 0 then
        --printIceDice("numberOfDice > 1")
        for i=1,numberOfDice do
            resultMod, total, result = setResult(numberOfDiceFace,result,valueToAdd,resultMod,total)
            if i == 1 then
                returnMsg = returnMsg..resultMod
            else
                returnMsg = returnMsg.." "..resultMod
            end
        end
        returnMsg = returnMsg.."]" --end result of roll
       --[[ if valueToAdd ~= 0 then
            returnMsg = returnMsg.." + "..valueToAdd
        end]]--
        returnMsg = compileText(tmpResult,total,valueToAdd,returnMsg)
        --printIceDice("returnMsgEnd = "..returnMsg)
   --[[ else
        resultMod, total, result = setResult(numberOfDiceFace,result,valueToAdd,resultMod,total)
        returnMsg = returnMsg..total.."]" --end result of roll
        if valueToAdd ~= 0 then
            returnMsg = returnMsg.." + "..valueToAdd
        end
        returnMsg = compileText(tmpResult,total,valueToAdd,returnMsg)]]--
    end


    
    -- If the roller is not the owner of the plugin adds his name to the message
  --[[  if clientID ~= fromID then
        returnMsg = "[b]"..fromName.."[/b] "..returnMsg
    end]]

    printIceDice("returnMsg = "..returnMsg)

    --returnMsg = compileText("","dice",total,resultMod)

    return returnMsg
end

IceDice = {
    diceRoller = diceRoller
}
