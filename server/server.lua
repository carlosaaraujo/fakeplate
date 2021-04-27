ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Config Webhook
local linkWebhook = "https://discord.com/api/webhooks/836424314689552394/BUERagjdgT6Pto9RsyUUjZ4AS7A3yqiA5ahuJpXLzEgGQSfu7WGELz-UHbVhtYm-Ye71"
local webhookName = "City Log"
local avatarWebhook = "https://i1.sndcdn.com/artworks-6x9vJH1uzKQJTOLF-xwsaTg-t500x500.jpg"

local authorName = "Fake Plate System"
local authorIcon = "https://i1.sndcdn.com/artworks-6x9vJH1uzKQJTOLF-xwsaTg-t500x500.jpg"

local footerText = "Fake Plate v1.2"
local descriptionText = "Successfully started and running ✅"

Citizen.CreateThread(function()
	local char = Config.PlateLetters
	char = char + Config.PlateNumbers
	if Config.PlateUseSpace then char = char + 1 end

	if char > 8 then
		print(('[fakeplate] [^3WARNING^7] Plate character count reached, %s/8 characters!'):format(char))
	end
end)

ESX.RegisterServerCallback('fakeplate:isPlateTaken', function(source, cb, plate)
	MySQL.Async.fetchAll('SELECT 1 FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(result)
		cb(result[1] ~= nil)
	end)
end)

ESX.RegisterUsableItem('fakeplate', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer.getInventoryItem("wrench").count

    if item > 0 then
        TriggerClientEvent('fakeplate:newPlate', source)
     else
         xPlayer.showNotification('You forgot a tool!')
     end
end)

ESX.RegisterUsableItem('oldplate', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer.getInventoryItem("wrench").count

    if item > 0 then
        TriggerClientEvent('fakeplate:oldPlate', source)
     else
         xPlayer.showNotification('You forgot a tool!')
     end
end)

RegisterServerEvent('fakeplate:useOld')
AddEventHandler('fakeplate:useOld', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('oldplate', 1)
end)

RegisterServerEvent('fakeplate:useFake')
AddEventHandler('fakeplate:useFake', function()
	local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.canSwapItem('fakeplate', 1, 'oldplate', 1) then
        xPlayer.removeInventoryItem('fakeplate', 1)
        xPlayer.addInventoryItem('oldplate', 1)
    else
        xPlayer.showNotification('Not enough inventory space.')
    end
end)

PerformHttpRequest(linkWebhook, function(err, text, headers) end, 'POST', json.encode({
    ['username'] = webhookName,
    ['avatar_url'] = avatarWebhook,
    ['embeds'] = {{
        ['author'] = {
            ['name'] = authorName,
            ['icon_url'] = authorIcon
        },
        ['footer'] = {
            ['text'] = footerText
        },
        ['color'] = 12914,
        ['description'] = descriptionText,
        ['timestamp'] = os.date('!%Y-%m-%dT%H:%M:%SZ')
    }}
}), {['Content-Type'] = 'application/json' })

RegisterServerEvent('fakeplate:dclog')
AddEventHandler('fakeplate:dclog', function(text)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    dclog(xPlayer, text)
end)

function dclog(xPlayer, text)
    local playerName = Sanitize(xPlayer.getName())
    
    for k, v in ipairs(GetPlayerIdentifiers(xPlayer.source)) do
        if string.match(v, 'discord:') then
            identifierDiscord = v
        end
        if string.match(v, 'ip:') then
            identifierIp = v
        end
    end
	
	local discord_webhook = GetConvar('discord_webhook', linkWebhook)
	if discord_webhook == '' then
	  return
	end
	local headers = {
	  ['Content-Type'] = 'application/json'
	}
	local data = {
        ['username'] = webhookName,
        ['avatar_url'] = avatarWebhook,
        ['embeds'] = {{
          ['author'] = {
            ['name'] = authorName,
            ['icon_url'] = authorIcon
          },
          ['footer'] = {
              ['text'] = footerText
          },
          ['color'] = 12914,
          ['timestamp'] = os.date('!%Y-%m-%dT%H:%M:%SZ')
        }}
      }
    text = '**'..text..'**\n🆔 **ID**: '..tonumber(xPlayer.source)..'\n💻 **Steam:** '..xPlayer.identifier..'\n📋 **Player name:** '..xPlayer.getName()
    if identifierDiscord ~= nil then
        text = text..'\n🛰️ **Discord:** <@'..string.sub(identifierDiscord, 9)..'>'
        identifierDiscord = nil
    end
    if identifierIp ~= nil then
        text = text..'\n🌐 **Ip:** '..string.sub(identifierIp, 4)
        identifierIp = nil
    end
    data['embeds'][1]['description'] = text
	PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end

function Sanitize(str)
	local replacements = {
		['&' ] = '&amp;',
		['<' ] = '&lt;',
		['>' ] = '&gt;',
		['\n'] = '<br/>'
	}

	return str
		:gsub('[&<>\n]', replacements)
		:gsub(' +', function(s)
			return ' '..('&nbsp;'):rep(#s-1)
		end)
end