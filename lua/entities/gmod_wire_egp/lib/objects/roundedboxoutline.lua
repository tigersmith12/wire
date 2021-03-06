-- Author: sk8 (& Divran)
local Obj = EGP:NewObject( "RoundedBoxOutline" )
Obj.angle = 0
Obj.radius = 16
Obj.size = 1
Obj.CanTopLeft = true
Obj.Draw = function( self )
	local xs,ys , sx,sy = self.x,self.y , self.w, self.h
    local polys = {}
    local source = { {x=-1,y=-1} , {x=1,y=-1} , {x=1,y=1} , {x=-1,y=1} }
    local radius = math.max(0,math.min((math.min(sx,sy)/2), self.radius ))
    local precision = 36
    local div,angle = 360/precision, -self.angle
    for x=1,4 do
        for i=0,(precision+1)/4 do
            local srx,sry = source[x].x,source[x].y
            local scx,scy = srx*(sx-(radius*2))/2 , sry*(sy-(radius*2))/2
            scx,scy = scx*math.cos(math.rad(angle)) - scy*math.sin(math.rad(angle)),
                      scx*math.sin(math.rad(angle)) + scy*math.cos(math.rad(angle))
            local a,r = math.rad(div*i+(x*90)), radius
            local dir = {x=math.sin(-(a+math.rad(angle))),y=math.cos(-(a+math.rad(angle)))}
            local dirUV = {x=math.sin(-a),y=math.cos(-a)}
            local ru,rv = (radius/sx),(radius/sy)
            local u,v = 0.5 + (dirUV.x*ru) + (srx/2)*(1-(ru*2)),
                        0.5 + (dirUV.y*rv) + (sry/2)*(1-(rv*2))
            polys[#polys+1] = {x=xs+scx+(dir.x*r),  y=ys+scy+(dir.y*r) , u=u,v=v}
        end
    end
	local n = #polys
    if polys and n>0 then
		surface.SetDrawColor(self.r,self.g,self.b,self.a)
		for i=1,n do
			local p1,p2 = polys[i],polys[1+i%n]
			EGP:DrawLine( p1.x, p1.y, p2.x, p2.y, self.size )
		end
    end
end
Obj.Transmit = function( self )
	EGP.umsg.Short((self.angle%360)*20)
	EGP.umsg.Short(self.radius)
	EGP.umsg.Short(self.size)
	self.BaseClass.Transmit( self )
end
Obj.Receive = function( self, um )
	local tbl = {}
	tbl.angle = um:ReadShort()/20
	tbl.radius = um:ReadShort()
	tbl.size = um:ReadShort()
	table.Merge( tbl, self.BaseClass.Receive( self, um ) )
	return tbl
end
Obj.DataStreamInfo = function( self )
	local tbl = {}
	table.Merge( tbl, self.BaseClass.DataStreamInfo( self ) )
	table.Merge( tbl, { angle = self.angle , radius = self.radius } )
	return tbl
end
