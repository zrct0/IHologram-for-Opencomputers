# 全息投影仪驱动程序
#### 快速创建物体，并支持移动，旋转，缩放
## API:

#### 1、IHologram:initialize(number size)

初始化投影仪

size:缩放倍数(即hologram.setScale(scale))

#### 2、IVector3:new(x,y,z)

创建一个3维向量

#### 3、Cube:create(IVector3 position, IVector3 size, number color)

创建一个长方体，返回的是object对象

#### 4、object:group(Object otherObject)

将2个物体组合成1个物体,并存储在object对象里

#### 5、object:setAbsAnchor(IVector3 pos or x, y, z)

设置物体的锚点（一般旋转时用）,传入的坐标应该为世界坐标

#### 6、旋转：
object:setRotation(IVector3 verctor3 or x, y, z)
object:setRotationX(number x)
object:setRotationY(number y)
object:setRotationZ(number z)

#### 7、平移：
object:setPosition(IVector3 verctor3 or x, y, z)

#### 8、缩放：
object:setScale(IVector3 verctor3 or x, y, z)

#### 9、销毁该物体：
object:clear()

# 使用例子
````lua
local H = require("IHologram")

local Vector3 = H.IVector3
local Cube = H.Cube

H:initialize(3) --设置整体缩放为3
H:clear()    --清屏	
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
````


