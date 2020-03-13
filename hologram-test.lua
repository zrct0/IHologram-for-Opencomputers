local H = require("IHologram")

local Vector3 = H.IVector3
local Cube = H.Cube

H:initialize(3) --设置整体缩放为3
H:clear()	--清屏	
local cube1 = Cube:create(Vector3:new(15,25,15), Vector3:new(3,3,15), 1)	--创建长方体1
local cube1_add = Cube:create(Vector3:new(35,25,15), Vector3:new(3,3,15), 1)--创建长方体1的附属方块
local cube2 = Cube:create(Vector3:new(25,15,15), Vector3:new(3,3,15), 3)	--创建长方体2
local cube2_add = Cube:create(Vector3:new(25,35,15), Vector3:new(3,3,15), 3)--创建长方体2的附属方块
local cube3 = Cube:create(H.Center, Vector3:new(8,8,8), 2)                  --创建长方体3 (中心方块)
cube1:group(cube1_add) --将长方体1与长方体1的附属方块组合
cube1:setAbsAnchor(H.Center)	--设置长方体1的锚点为投影仪的中心点
cube2:group(cube2_add) --将长方体2与长方体2的附属方块组合
cube2:setAbsAnchor(H.Center)	--设置长方体2的锚点为投影仪的中心点
while true do
	for i=0, math.pi * 2 , math.pi / 32 do 
		cube1:setRotation(0,0,i)	--方块1按z轴旋转
		cube2:setRotation(i,0,0)	--方块2按x轴旋转
		cube3:setRotation(i,-i,i)   --方块3按x、-y、z轴旋转
	end
end	


