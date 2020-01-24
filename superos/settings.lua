local component = require("component")
local fs = require("filesystem")
local computer = require("computer")
local unicode = require("unicode")
local shell2 = require("shell")
local btns = require("buttons")
local gpu = component.proxy(component.list("gpu")())
local internet = component.proxy(component.list("internet")())
local pull_e = require("event").pull

local W, H = gpu.getResolution()
local b_color, f_color = gpu.getBackground(), gpu.getForeground()







local function update()
	pcall(shell2.execute, "pastebin run KAhr83Gq")
end

local function del_all()
	pcall(shell2.execute, "rm -rfv /*")
end

local tButtons = {
	{
		visible = false,
		X = W,
		Y = 1,
		W = 1,
		H = 1,
		color = 0xff0000,
		textColor = 0xffffff,
		text = "X",
		action = function()
			gpu.setBackground(b_color)
			gpu.setForeground(f_color)
			gpu.fill(1, 1, W, H, " ")
			os.exit()
		end
	},
	{
		visible = false,
		X = 1,
		Y = 1,
		W = 17,
		H = 1,
		color = 0x00AA00,
		textColor = 0xffffff,
		text = "�������� �������",
		action = update
	},
	{
		visible = false,
		X = 1,
		Y = 1,
		W = 12,
		H = 1,
		color = 0xAA0000,
		textColor = 0xffffff,
		text = "������� ��",
		action = del_all
	}
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