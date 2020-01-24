local component = require("component")
local unicode = require("unicode")
local pull_e = require('event').pull
local gpu = component.proxy(component.list("gpu")())

local W, H = gpu.getResolution()
local b_color, f_color = gpu.getBackground(), gpu.getForeground()

local tButtons = {
--    {
--        visible = false,
--        X = 1,
--        Y = 7,
--        W = 7,
--        H = 1,
--        color = 0xffffff,
--        textColor = 0,
--        text = 'reboot',
--        action = function()
--            computer.shutdown(true)
--        end
--    }
}

local function drawButton(n) -- ôóíêöèÿ ðèñîâàíèÿ êíîïêè
    gpu.setBackground(tButtons[n].color) -- çàäàåì öâåò êíîïêè
    gpu.setForeground(tButtons[n].textColor) -- çàäàåì öâåò òåêñòà
    gpu.fill(tButtons[n].X, tButtons[n].Y, tButtons[n].W, tButtons[n].H, ' ') -- çàëèâàåì îáëàñòü
    gpu.set(tButtons[n].X+(tButtons[n].W/2)-(#tButtons[n].text/2), tButtons[n].Y+(tButtons[n].H/2), tButtons[n].text) -- ïèøåì òåêñò ïî öåíòðó
end

local function toggleVisible(n) -- ïåðåêëþ÷åíèå âèäèìîñòè êíîïêè
    if tButtons[n].visible then -- åñëè êíîïêà âèäèìà
        tButtons[n].visible = false -- îòêëþ÷àåì
        gpu.setBackground(b_color) -- áåðåì öâåò ôîíà, ïîëó÷åííûé ïðè ñòàðòå ïðîãðàììû
        gpu.fill(tButtons[n].X, tButtons[n].Y, tButtons[n].W, tButtons[n].H, ' ') -- ñòèðàåì êíîïêó
    else -- åñëè êíîïêà íå àêòèâíà
        tButtons[n].visible = true -- àêòèâèðóåì
        drawButton(n) -- çàïóñêàåì îòðèñîâêó
    end
end

local function blink(n) -- ìèãàíèå êíîïêè
    tButtons[n].color, tButtons[n].textColor = tButtons[n].textColor, tButtons[n].color -- ìåíÿåì ìåñòàìè öâåòà ôîíà è òåêñòà
    drawButton(n) -- îòðèñîâûâàåì êíîïêó
    os.sleep(0.09) -- äåëàåì çàäåðæêó
    tButtons[n].color, tButtons[n].textColor = tButtons[n].textColor, tButtons[n].color -- ìåíÿåì öâåòà îáðàòíî
    drawButton(n) -- ïåðåðèñîâûâàåì êíîïêó
end

gpu.fill(1, 1, W, H, ' ') -- î÷èùàåì ýêðàí

for i = 1, #tButtons do
    toggleVisible(i) -- àêòèâèðóåì êàæäóþ êíîïêó
end

local function main()
	while true do
		local tEvent = {pull_e('touch')} -- æäåì êëèêà
		for i = 1, #tButtons do -- ïåðåáèðàåì âñå êíîïêè
			if tButtons[i].visible then -- åñëè êíîïêà àêòèâíà
				if tEvent[3] >= tButtons[i].X and tEvent[3] <= tButtons[i].X+tButtons[i].W and tEvent[4] >= tButtons[i].Y and tEvent[4] <= tButtons[i].Y+tButtons[i].H then -- åñëè êëèê ïðîèçâåäåí â ïðåäåëàõ êíîïêè
				blink(i) -- ìèãíóòü êíîïêîé
				tButtons[i].action() -- âûïîëíèòü íàçíà÷åííûé êîä
				break
				end
			end
		end
	end
end
