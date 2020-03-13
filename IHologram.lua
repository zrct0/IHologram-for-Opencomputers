--全息投影仪驱动程序
--快速创建物体，并支持移动，旋转，缩放
--API:
--1、IHologram:initialize(number size)
--初始化投影仪
--size:缩放倍数(即hologram.setScale(scale))

--2、IVector3:new(x,y,z)
--创建一个3维向量

--3、Cube:create(IVector3 position, IVector3 size, number color)
--创建一个长方体，返回的是object对象

--4、object:group(Object otherObject)
--将2个物体组合成1个物体,并存储在object对象里

--5、object:setAbsAnchor(IVector3 pos or x, y, z)
--设置物体的锚点（一般旋转时用）,传入的坐标应该为世界坐标

--6、旋转：
--object:setRotation(IVector3 verctor3 or x, y, z)
--object:setRotationX(number x)
--object:setRotationY(number y)
--object:setRotationZ(number z)

--7、平移：
--object:setPosition(IVector3 verctor3 or x, y, z)

--8、缩放：
--object:setScale(IVector3 verctor3 or x, y, z)

--9、销毁该物体：
--object:clear()

--使用例子
--local H = require("IHologram")
--H:initialize(3) --设置整体缩放为3
--H:clear() --清屏
--local cube1 = Cube:create(Vector3:new(15,25,15), Vector3:new(3,3,15), 1) --创建长方体1
--cube1:setRotation(0,0,math.pi / 4) --长方体1延z轴旋转45度

local IHologram = {}
local IVector3 = {} --3维向量
local IRect3 = {}	--3维区域
local Matrix4x4 = {}--4x4矩阵
local Object = {}	--物体
local Cube = {}		--长方体

local component = require("component")
local text = require("text")
local hologram = component.hologram

IHologram.IVector3 = IVector3
IHologram.IRect3 = IRect3
IHologram.Matrix4x4 = Matrix4x4
IHologram.Cube = Cube

IHologram.objects = {}
IHologram.Center = nil


function IHologram:new(scale)
	local t = {}
	setmetatable(t, self)
	self.__index = self 
	t:initialize(scale)
	return t
end

function IHologram:initialize(scale)
	IHologram.Center = IVector3:new(25,25,12)
	hologram.setScale(scale)
	self:clear()
end

--清屏
function IHologram:clear()
	self:display(IRect3:new(IVector3:new(1,1,1), IVector3:new(48,48,32)), false)
end

--根据IRect显示一个区域
function IHologram:display(r, color)
	for x = r.min.x , r.max.x do
		for y = r.min.y , r.max.y do
			hologram.fill(x, y, r.min.z, r.max.z, color)	
		end
	end
end

--<============IVector3=============>

IVector3.x = 0
IVector3.y = 0
IVector3.z = 0
IVector3.vtable = {0, 0, 0, 1}

--根据x,y,z创建向量
function IVector3:new(x,y,z)
	local t = {}
	setmetatable(t, self)
	self.__index = self
	t:initialize(x,y,z)
	return t
end

function IVector3:initialize(x,y,z)
	self.x = x
	self.y = y
	self.z = z  
	self.vtable = {x, y, z, 1}
end

--向量相加
function IVector3:add(v)
	return IVector3:new(self.x + v.x, self.y + v.y, self.z + v.z)
end

--向量相减
function IVector3:sub(v)
	return IVector3:new(self.x - v.x, self.y - v.y, self.z - v.z)
end

--向量相乘
function IVector3:mul(v)
	if type(v) == "number" then
		return IVector3:new(self.x * v, self.y * v, self.z * v)
	end
	return IVector3:new(self.x * v.x, self.y * v.y, self.z * v.z)
end

--向量相除
function IVector3:div(v)
	if type(v) == "number" then
		return IVector3:new(self.x / v, self.y / v, self.z / v)	
	end
	return IVector3:new(self.x / v.x, self.y / v.y, self.z / v.z)
end

--向量的绝对值
function IVector3:abs()	
	return IVector3:new(math.abs(self.x), math.abs(self.y), math.abs(self.z))
end

--四舍五入取整数
function IVector3:roundInt()	
	return IVector3:new(math.floor(self.x + 0.5), math.floor(self.y + 0.5), math.floor(self.z + 0.5))
end

--向量的比较
function IVector3:__eq(v)	
	return v and self.x == v.x and self.y == v.y and self.z == v.z
end

--求插值
--t为间隔
--返回从 from 到 to的连接线上的一系列值（存在表中）
--公式 from + (to - from)
function IVector3:lerp(from, to, t)
	local vs = {}
	local dv = to:sub(from)		
	local interval = math.floor(from:distance(to) / t)	
	local iv = dv:div(interval)	
	local lastNv = nil	
	for i=0, interval do
		local nv = from:add(iv:mul(i)):roundInt()
		if not (nv == lastNv) then			
			table.insert(vs, nv)			
		end
		lastNv = nv
	end
	return vs
end

--两点之间的距离
function IVector3:distance(v)
	local dx2 = math.pow(self.x - v.x, 2)
	local dy2 = math.pow(self.y - v.y, 2)
	local dz2 = math.pow(self.z - v.z, 2)	
	return math.sqrt(dx2 + dy2 + dz2)
end  

function IVector3:get(i)
	return self.vtable[i]
end

function IVector3:__tostring()
	return "("..self.x..","..self.y..","..self.z..")"
end 



--<============IRect3=============>

IRect3.min = nil
IRect3.max = nil
IRect3.size = nil
IRect3.center = nil

--创建一个区域
--构造方法1：new(IRect3 rect) 将rect复制一份
--构造方法2：new(IVector3 v1, IVector3 v2, boolean createWithCenter) 以向量v1, 和v2创建。
--           如果createWithCenter为true，则v1为该区域的最中心点, v2为该区域的大小
--           如果createWithCenter为false，则v1为该区域的最小坐标点, v2为该区域的最大坐标点
function IRect3:new(v1, v2, createWithCenter)
	local t = {}
	setmetatable(t, self)
	self.__index = self
	t:initialize(v1, v2, createWithCenter)
	return t
end

function IRect3:initialize(v1, v2, createWithCenter)
	if createWithCenter then
		self.center = v1
		self.size = v2
		self.min = self.center:sub(self.size:div(2))
		self.max = self.center:add(self.size:div(2))		
	else
		if v2 then
			self.min = v1	
			self.size = v2
			self.max = self.min:add(self.size)
			self.center = self.min:add(self.size:div(2))
		else
			self.min = v1.min	
			self.size = v1.size
			self.max = v1.max
			self.center = v1.center
		end
	end
end

--将该区域转换为一系列坐标点
--frame为true则只包括外边框
function IRect3:toShape(frame)
	local shape = {}	
	for x = self.min.x , self.max.x do
		for y = self.min.y , self.max.y do
			for z = self.min.z , self.max.z do
				if not frame or x == self.min.x or x == self.max.x or y == self.min.y or y == self.max.y or z == self.min.z or z == self.max.z then
					table.insert(shape, IVector3:new(x -1, y -1, z -1):sub(self.center))					
				end
			end
		end
	end	
	return shape
end

function IRect3:__tostring()
	return "IRect3(min:"..self.min:__tostring().." max"..self.max:__tostring()..")"
end 

--<============Matrix4x4=============>
--4x4矩阵
Matrix4x4.matrixTable = nil

--创建矩阵
--例子：
--local a = Matrix4x4:new({1,2,1,0, 0,2,0,1, 4,0,0,0, 5,1,1,2})
function Matrix4x4:new(_table)
	local t = {}
	setmetatable(t, self)
	self.__index = self
	t:initialize(_table)
	return t
end

function Matrix4x4:initialize(_table)
	_table = _table or {0,0,0,0, 0,0,0,0, 0,0,0,0 ,0,0,0,0}
	self.matrixTable = _table
end

function Matrix4x4:get(y, x)
	return self.matrixTable[(y - 1) * 4 + x]
end

function Matrix4x4:set(y, x, v)
	self.matrixTable[(y - 1) * 4 + x] = v
end


--矩阵的叉乘
--例子：
--local a = Matrix4x4:new({1,2,1,0, 0,2,0,1, 4,0,0,0, 5,1,1,2})
--local b = Matrix4x4:new({5,2,1,3, 9,3,6,1, 3,2,7,2, 6,1,1,2})
--local c = a:mul(b)	
function Matrix4x4:mul(b)	
	local a = self	
	local nm = Matrix4x4:new()
	for x = 1, 4 do
		for y = 1, 4 do
			local value = 0
			for i = 1, 4 do
				value = value + a:get(y, i) * b:get(i, x)
			end
			nm:set(y, x, value)
		end
	end
	return nm
end

function Matrix4x4:__tostring()
	local t = self.matrixTable
	local str = "("
	for y = 1, 4 do
		str = str.."["
			for x = 1, 4 do				
				str = str..(text.padLeft(tostring(t[(y - 1) * 4 + x]), 2))
				if x ~= 4 then
					str = str..","
				end
			end
		str = str.."]"
	end
	str = str..")"
	return str
end

--<============Object=============>
--用于显示的物体对象
Object.shape = {}            --物体的外形（该物体所包含的所有点的坐标）
Object.worldSpace = nil      --该物体所有点的世界坐标
Object.position = nil		 --该物体的位置坐标
Object.rotation = {0,0,0}	 --该物体的旋转坐标
Object.scale = {1,1,1}       --该物体的缩放坐标
Object.color = nil           --该物体的颜色
Object.MatrixRotationX = nil --X轴旋转矩阵
Object.MatrixRotationY = nil --Y轴旋转矩阵
Object.MatrixRotationZ = nil --Z轴旋转矩阵
Object.MatrixRotation = nil  --旋转矩阵
Object.MatrixScale = nil     --缩放矩阵
Object.MatrixPosition = nil  --位移矩阵
Object.MatrixModel = {}      --模型世界空间转换矩阵
 
function Object:new(_position, _shape, _color)
	local t = {}
	setmetatable(t, self)
	self.__index = self
	t:initialize(_position, _shape, _color)
	table.insert(IHologram.objects, t)
	return t
end

function Object:initialize(_position, _shape, _color)	
	self.shape = _shape
	self.color = _color
	self:setPosition(_position, true)
	self:setRotation(0, 0, 0, true)
	self:setScale(1, 1, 1, true)
	self:display()
end

--物体延X轴旋转到指定角度
function Object:setRotationX(v, ignoreDisplay)
	self.rotation[1] = v
	local cosV = math.cos(v)
	local sinV = math.sin(v)
	self.MatrixRotationX = Matrix4x4:new({1,0,0,0,  0,cosV,-sinV,0,  0,sinV,cosV,0,  0,0,0,1})
	if not ignoreDisplay then
		self:updateRotationMatrix(ignoreDisplay)
	end
end

--物体延Y轴旋转到指定角度
function Object:setRotationY(v, ignoreDisplay)
	self.rotation[2] = v
	local cosV = math.cos(v)
	local sinV = math.sin(v)
	self.MatrixRotationY = Matrix4x4:new({cosV,0,sinV,0,  0,1,0,0,  -sinV,0,cosV,0,  0,0,0,1})
	if not ignoreDisplay then
		self:updateRotationMatrix(ignoreDisplay)
	end
end

--物体延Z轴旋转到指定角度
function Object:setRotationZ(v, ignoreDisplay)
	self.rotation[3] = v
	local cosV = math.cos(v)
	local sinV = math.sin(v)
	self.MatrixRotationZ = Matrix4x4:new({cosV,-sinV,0,0,  sinV,cosV,0,0,  0,0,1,0,  0,0,0,1})
	if not ignoreDisplay then
		self:updateRotationMatrix(ignoreDisplay)
	end
end

--物体延X、Y、Z轴旋转到指定角度
function Object:setRotation(x, y, z, ignoreDisplay)
	local newRotation
	if y and z then
		newRotation = IVector3:new(x, y ,z)
	else
		newRotation = x
		ignoreDisplay = y
	end		
	self:setRotationX(newRotation.x, true)
	self:setRotationY(newRotation.y, true)
	self:setRotationZ(newRotation.z, true)
	self:updateRotationMatrix(ignoreDisplay)	
end

--更新旋转矩阵
function Object:updateRotationMatrix(ignoreDisplay)
	local x = self.MatrixRotationX
	local y = self.MatrixRotationY
	local z = self.MatrixRotationZ
	self.MatrixRotation = (z:mul(x)):mul(y)
	if not ignoreDisplay then
		self:display()
	end
end

--设置物体的位置
function Object:setPosition(x, y, z, ignoreDisplay)
	local newpos
	if y and z then
		newpos = IVector3:new(x, y ,z)
	else
		newpos = x
		ignoreDisplay = y
	end		
	self.position = newpos
	self.MatrixPosition = Matrix4x4:new({1,0,0,newpos.x,  0,1,0,newpos.y,  0,0,1,newpos.z,  0,0,0,1})
	if not ignoreDisplay then
		self:display()
	end
end

--设置物体的缩放
function Object:setScale(x, y ,z, ignoreDisplay)
	local newScale
	if y and z then
		newScale = IVector3:new(x, y ,z)
	else
		newScale = x
		ignoreDisplay = y
	end		
	self.scale = newScale
	self.MatrixScale = Matrix4x4:new({newScale.x,0,0,0,  0,newScale.y,0,0,  0,0,newScale.z,0,  0,0,0,1})
	if not ignoreDisplay then
		self:display()
	end
end

--设置模型世界空间转换矩阵
function Object:updateModelMatrix()
	local r = self.MatrixRotation
	local t = self.MatrixPosition
	local s = self.MatrixScale	
	self.MatrixModel = (t:mul(r)):mul(s)	
end

--以interval的时间间隔移动到v坐标
function Object:move(v, interval)	
	local lerpTable = IVector3:lerp(self.position, v, 0.5)
	for k, v in pairs(lerpTable) do 
		self:setPosition(v)
		self:display()
		if interval then
			os.sleep(interval)
		end
	end	
end

--设置物体的锚点（一般旋转时用）
function Object:setAbsAnchor(x, y, z)
	local newAnchor
	if y and z then
		newAnchor = IVector3:new(x, y ,z)
	else
		newAnchor = x	
	end	
	local dv = self.position:sub(newAnchor)
	for k, v in pairs(self.shape) do 
		self.shape[k] = self.shape[k]:add(dv)
	end	
	self:setPosition(newAnchor)
end

--和另一物体组合在一起
function Object:group(otherObject)
	for k, v in pairs(otherObject.shape) do 
		local worldPos = otherObject:modelPointTransform(v)
		table.insert(self.shape, worldPos:sub(self.position))
	end
end

--将坐标的从模型空间转换到世界坐标
function Object:modelPointTransform(p)
	local a = self.MatrixModel
	local np4 = {}	
	for y = 1, 4 do
		local value = 0
		for i = 1, 4 do
			value = value + a:get(y, i) * p:get(i)
		end
		table.insert(np4, value)
	end	
	return IVector3:new(np4[1], np4[2], np4[3]):roundInt()
end

--显示
function Object:display()	
	local color = self.color
	--创建新的世界坐标系,并绘制	
	self:updateModelMatrix()	
	local newWorldSpace = {}
	for k, v in pairs(self.shape) do 
		local np = self:modelPointTransform(v)
		table.insert(newWorldSpace, np)			
		hologram.set(np.x, np.z, np.y, color)
	end
	
	if self.worldSpace then
		--移除旧的图像		
		for k, op in pairs(self.worldSpace) do 		
			if not table.contains(newWorldSpace, op) then				
				hologram.set(op.x, op.z, op.y, false)
			end
		end	
	end
	self.worldSpace = newWorldSpace
end



--<============Cube=============>
--创建一个长方体
function Cube:create(_position, _size, _color)	
	hologram.set(_position.x, _position.z, _position.y, true)
	return Object:new(_position, IRect3:new(_position, _size, true):toShape(true), _color)	
end

--<============辅助函数=============>
function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function getFunctionName()
	return debug.getinfo(2).name
end

return IHologram