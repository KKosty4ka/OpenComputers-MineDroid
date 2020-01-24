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
--        textColor = 0,s
--        text = 'reboot',
--        action = function()
--            computer.shutdown(true)
--        end
--    }
}

local function drawButton(n) -- ������� ��������� ������
    gpu.setBackground(tButtons[n].color) -- ������ ���� ������
    gpu.setForeground(tButtons[n].textColor) -- ������ ���� ������
    gpu.fill(tButtons[n].X, tButtons[n].Y, tButtons[n].W, tButtons[n].H, ' ') -- �������� �������
    gpu.set(tButtons[n].X+(tButtons[n].W/2)-(#tButtons[n].text/2), tButtons[n].Y+(tButtons[n].H/2), tButtons[n].text) -- ����� ����� �� ������
end

local function toggleVisible(n) -- ������������ ��������� ������
    if tButtons[n].visible then -- ���� ������ ������
        tButtons[n].visible = false -- ���������
        gpu.setBackground(b_color) -- ����� ���� ����, ���������� ��� ������ ���������
        gpu.fill(tButtons[n].X, tButtons[n].Y, tButtons[n].W, tButtons[n].H, ' ') -- ������� ������
    else -- ���� ������ �� �������
        tButtons[n].visible = true -- ����������
        drawButton(n) -- ��������� ���������
    end
end

local function blink(n) -- ������� ������
    tButtons[n].color, tButtons[n].textColor = tButtons[n].textColor, tButtons[n].color -- ������ ������� ����� ���� � ������
    drawButton(n) -- ������������ ������
    os.sleep(0.09) -- ������ ��������
    tButtons[n].color, tButtons[n].textColor = tButtons[n].textColor, tButtons[n].color -- ������ ����� �������
    drawButton(n) -- �������������� ������
end

gpu.fill(1, 1, W, H, ' ') -- ������� �����

for i = 1, #tButtons do
    toggleVisible(i) -- ���������� ������ ������
end

local function main()
	while true do
		local tEvent = {pull_e('touch')} -- ���� �����
		for i = 1, #tButtons do -- ���������� ��� ������
			if tButtons[i].visible then -- ���� ������ �������
				if tEvent[3] >= tButtons[i].X and tEvent[3] <= tButtons[i].X+tButtons[i].W and tEvent[4] >= tButtons[i].Y and tEvent[4] <= tButtons[i].Y+tButtons[i].H then -- ���� ���� ���������� � �������� ������
				blink(i) -- ������� �������
				tButtons[i].action() -- ��������� ����������� ���
				break
				end
			end
		end
	end
end