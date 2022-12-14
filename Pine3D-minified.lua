local a=require("betterblittle")local b={}for c=1,16 do b[2^(c-1)]="0123456789abcdef":sub(c,c)end;local d=math.pow(10,99)function linear(e,f,g,h)local i=g-e;if i==0 then return d,-d*e end;local j=(h-f)/i;return j,f-j*e end;local k=math.min;local l=math.max;local m=math.floor;local n=math.ceil;function newBuffer(e,f,g,h)local o={x1=e,y1=f,x2=g,y2=h,width=g-e+1,height=h-f+1,screenBuffer={{}},blittleWindow=nil,blittleOn=false,backgroundColor=colors.lightBlue}function o:setBufferSize(e,f,g,h)self.x1=e;self.y1=f;self.x2=g;self.y2=h;self.width=g-e+1;self.height=h-f+1;if self.blittleWindow then self.blittleWindow=self.blittleWindow.reposition(self.x1,self.y1,self.x1+self.width-1,self.y1+self.height-1)end;self:clear()end;function o:clear()local p=self.screenBuffer;p.c2={}local q=p.c2;local r=self.width;local s=self.backgroundColor;if self.blittleOn then for t=1,self.height do q[t]={}local u=q[t]for v=1,r do u[v]=s end end else local w=b[s]p.c1={}local x=p.c1;p.chars={}local y=p.chars;for t=1,self.height do x[t]={}q[t]={}y[t]={}local z=x[t]local u=q[t]local A=y[t]for v=1,r do z[v]=w;u[v]=w;A[v]=" "end end end end;function o:fastClearNormal()local B=self.backgroundColor;local p=self.screenBuffer;local y=p.chars;local x=p.c1;local q=p.c2;local B=b[B]local r=self.width;for t=1,self.height do local A=y[t]local z=x[t]local u=q[t]for v=1,r do A[v]=" "z[v]=B;u[v]=B end end end;function o:fastClearBLittle()local B=self.backgroundColor;local q=self.screenBuffer.c2;local r=self.width;for t=1,self.height do local u=q[t]for v=1,r do u[v]=B end end end;function o:setPixel(v,t,x,q,C)local v=math.floor(v+0.5)local t=math.floor(t+0.5)if v>=1 and v<=self.width then if t>=1 and t<=self.height then local p=self.screenBuffer;if self.blittleOn then p.c2[t][v]=q or x else p.c1[t][v]=b[x]p.c2[t][v]=b[q or x]p.chars[t][v]=" "end end end end;function o:image(i,D,E)for t,F in pairs(E)do for v,G in pairs(F)do if G and G>0 then if self.blittleOn then self:setPixel(v+(i-1)*2,t+(D-1)*3,G,G," ")else self:setPixel(v+i-1,t+D-1,G,G," ")end end end end end;function o:loadLineNormal(e,f,g,h,B,C,H,j,I)local p=self.screenBuffer;local x=p.c1;local q=p.c2;local y=p.chars;local J=self.width;local K=self.height;if g>=e then for v=l(n(e),1),k(m(g),J)do local t=m(j*v+I+0.5)if t>0 and t<=K then x[t][v]=H;q[t][v]=B;y[t][v]=C end end else for v=l(n(g),1),k(m(e),J)do local t=m(j*v+I+0.5)if t>0 and t<=K then x[t][v]=H;q[t][v]=B;y[t][v]=C end end end;if h>=f then for t=l(n(f),1),k(m(h),K)do local v=m((t-I)/j+0.5)if v>0 and v<=J then x[t][v]=H;q[t][v]=B;y[t][v]=C end end else for t=l(n(h),1),k(m(f),K)do local v=m((t-I)/j+0.5)if v>0 and v<=J then x[t][v]=H;q[t][v]=B;y[t][v]=C end end end end;function o:loadLineBLittle(e,f,g,h,B,j,I)local p=self.screenBuffer;local q=p.c2;local J=self.width;local K=self.height;if g>=e then for v=l(n(e),1),k(m(g),J)do local t=m(j*v+I+0.5)if t>0 and t<=K then q[t][v]=B end end else for v=l(n(g),1),k(m(e),J)do local t=m(j*v+I+0.5)if t>0 and t<=K then q[t][v]=B end end end;if h>=f then for t=l(n(f),1),k(m(h),K)do local v=m((t-I)/j+0.5)if v>0 and v<=J then q[t][v]=B end end else for t=l(n(h),1),k(m(f),K)do local v=m((t-I)/j+0.5)if v>0 and v<=J then q[t][v]=B end end end end;function o:horLineNormal(L,M,N,O,P,Q,B,C,H)local p=self.screenBuffer;local x=p.c1;local q=p.c2;local y=p.chars;local J=self.width;local K=self.height;for t=l(k(n(P),K+1),1),k(m(Q),K)do local e=(t-M)/L;local g=(t-O)/N;local z=x[t]local u=q[t]local A=y[t]if e<g then for v=l(k(m(e+0.5),J+1),1),k(g,J)do z[v]=H;u[v]=B;A[v]=C end else for v=l(k(m(g+0.5),J+1),1),k(e,J)do z[v]=H;u[v]=B;A[v]=C end end end end;function o:horLineBLittle(L,M,N,O,P,Q,B)local p=self.screenBuffer;local q=p.c2;local J=self.width;local K=self.height;for t=l(k(n(P),K+1),1),k(m(Q),K)do local e=(t-M)/L;local g=(t-O)/N;local u=q[t]if e<g then for v=l(k(m(e+0.5),J+1),1),k(g,J)do u[v]=B end else for v=l(k(m(g+0.5),J+1),1),k(e,J)do u[v]=B end end end end;local R=colors.black;function o:drawTriangleNormal(e,f,g,h,S,T,B,C,H,U)if e<0 and g<0 and S<0 or f<0 and h<0 and T<0 then return end;local J=self.width;if e>J and g>J and S>J then return end;local K=self.height;if f>K and h>K and T>K then return end;C=C or" "H=H or B;local B=b[B]local H=b[H]local L,M=linear(e,f,g,h)local N,O=linear(g,h,S,T)local V,W=linear(e,f,S,T)local X=self.horLineNormal;if f<=h and f<=T then if h<=T then if L~=0 then X(self,L,M,V,W,f,h,B,C,H)end;if N~=0 then X(self,N,O,V,W,h,T,B,C,H)end else if V~=0 then X(self,L,M,V,W,f,T,B,C,H)end;if N~=0 then X(self,L,M,N,O,T,h,B,C,H)end end elseif h<=f and h<=T then if f<=T then if L~=0 then X(self,L,M,N,O,h,f,B,C,H)end;if V~=0 then X(self,N,O,V,W,f,T,B,C,H)end else if N~=0 then X(self,L,M,N,O,h,T,B,C,H)end;if V~=0 then X(self,L,M,V,W,T,f,B,C,H)end end else if f<=h then if V~=0 then X(self,N,O,V,W,T,f,B,C,H)end;if L~=0 then X(self,L,M,N,O,f,h,B,C,H)end else if N~=0 then X(self,N,O,V,W,T,h,B,C,H)end;if L~=0 then X(self,L,M,V,W,h,f,B,C,H)end end end;local U=U;if U or self.triangleEdges then local Y=self.loadLineNormal;local B=b[U or R]Y(self,e,f,g,h,B,C,H,L,M)Y(self,g,h,S,T,B,C,H,N,O)Y(self,S,T,e,f,B,C,H,V,W)end end;function o:drawTriangleBLittle(e,f,g,h,S,T,B,C,H,U)if e<0 and g<0 and S<0 or f<0 and h<0 and T<0 then return end;local J=self.width;if e>J and g>J and S>J then return end;local K=self.height;if f>K and h>K and T>K then return end;local L,M=linear(e,f,g,h)local N,O=linear(g,h,S,T)local V,W=linear(e,f,S,T)local X=self.horLineBLittle;if f<=h and f<=T then if h<=T then if L~=0 then X(self,L,M,V,W,f,h,B)end;if N~=0 then X(self,N,O,V,W,h,T,B)end else if V~=0 then X(self,L,M,V,W,f,T,B)end;if N~=0 then X(self,L,M,N,O,T,h,B)end end elseif h<=f and h<=T then if f<=T then if L~=0 then X(self,L,M,N,O,h,f,B)end;if V~=0 then X(self,N,O,V,W,f,T,B)end else if N~=0 then X(self,L,M,N,O,h,T,B)end;if V~=0 then X(self,L,M,V,W,T,f,B)end end else if f<=h then if V~=0 then X(self,N,O,V,W,T,f,B)end;if L~=0 then X(self,L,M,N,O,f,h,B)end else if N~=0 then X(self,N,O,V,W,T,h,B)end;if L~=0 then X(self,L,M,V,W,h,f,B)end end end;local U=U;if U or self.triangleEdges then local Y=self.loadLineBLittle;local B=U or R;Y(self,e,f,g,h,B,L,M)Y(self,g,h,S,T,B,N,O)Y(self,S,T,e,f,B,V,W)end end;function o:drawBufferNormal()local e=self.x1;local f=self.y1;local p=self.screenBuffer;local Z=term.setCursorPos;local _=term.blit;local y=p.chars;local x=p.c1;local q=p.c2;local a0=table.concat;for t=1,self.height do Z(e,t+f-1)local y=a0(y[t])local x=a0(x[t])local q=a0(q[t])_(y,x,q)end end;function o:drawBufferBLittle()local a1=self.blittleWindow;if not a1 then self.blittleWindow=window.create(term.current(),self.x1,self.y1,self.x1+self.width-1,self.y1+self.height-1,false)a1=self.blittleWindow end;a.drawBuffer(self.screenBuffer.c2,a1)a1.setVisible(true)a1.setVisible(false)end;function o:highResMode(a2)self.blittleOn=a2;self.drawTriangle=a2 and self.drawTriangleBLittle or self.drawTriangleNormal;self.fastClear=a2 and self.fastClearBLittle or self.fastClearNormal;self.drawBuffer=a2 and self.drawBufferBLittle or self.drawBufferNormal;self:clear()end;function o:useTriangleEdges(a2)self.triangleEdges=a2 end;o:highResMode(true)return o end;local a3=3/2;local a4=math.sqrt;local a5=table.sort;local function a6(a7)local a8=a7[1][16]for c=2,#a7 do local a9=a7[c][16]if a9>a8 then return false end;a8=a9 end;return true end;local function aa(a7,ab,ac,ad,ae)local af=ae[1]local ag=ae[2]local ah=ae[3]local ai=ab and ab-af or 0;local aj=ac and ac-ag or 0;local ak=ad and ad-ah or 0;for c=1,#a7 do local al=a7[c]local am=ai+(al[1]+al[4]+al[7])/3;local an=aj+(al[2]+al[5]+al[8])/3;local ao=ak+(al[3]+al[6]+al[9])/3;al[16]=am*am+an*an+ao*ao end;if not a6(a7)then a5(a7,function(j,I)return j[16]>I[16]end)end end;local ap=math.deg;local aq=math.rad;local ar=math.sin;local as=math.cos;local at=math.atan;local au=math.atan2;local function av(v,t,aw,ax)local ay=au(t+0.0000001,aw+0.0000001)local az=ay+ax;while az>180 do az=az-360 end;while az<-180 do az=az+360 end;local aA=a4(t*t+aw*aw)local t=aA*ar(az)local aw=aA*as(az)return v,t,aw end;local function aB(v,t,aw,aC)local ay=au(v+0.0000001,aw+0.0000001)local az=ay+aC;while az>180 do az=az-360 end;while az<-180 do az=az+360 end;local aA=a4(v*v+aw*aw)local v=aA*ar(az)local aw=aA*as(az)return v,t,aw end;local function aD(v,t,aw,aE)local ay=au(v+0.0000001,t+0.0000001)local az=ay+aE;while az>180 do az=az-360 end;while az<-180 do az=az+360 end;local aA=a4(v*v+t*t)local v=aA*ar(az)local t=aA*as(az)return v,t,aw end;local function aF(aG,ax)local aH={}for aI,al in pairs(aG)do local e,f,aJ=av(al[1],al[2],al[3],ax)local g,h,aK=av(al[4],al[5],al[6],ax)local S,T,aL=av(al[7],al[8],al[9],ax)aH[#aH+1]={e,f,aJ,g,h,aK,S,T,aL}aH[#aH][10]=al[10]aH[#aH][11]=al[11]aH[#aH][12]=al[12]aH[#aH][13]=al[13]aH[#aH][14]=al[14]end;return aH end;local function aM(aG,aC)local aH={}for aI,al in pairs(aG)do local e,f,aJ=aB(al[1],al[2],al[3],aC)local g,h,aK=aB(al[4],al[5],al[6],aC)local S,T,aL=aB(al[7],al[8],al[9],aC)aH[#aH+1]={e,f,aJ,g,h,aK,S,T,aL}aH[#aH][10]=al[10]aH[#aH][11]=al[11]aH[#aH][12]=al[12]aH[#aH][13]=al[13]aH[#aH][14]=al[14]end;return aH end;local function aN(aG,aE)local aH={}for aI,al in pairs(aG)do local e,f,aJ=aD(al[1],al[2],al[3],aE)local g,h,aK=aD(al[4],al[5],al[6],aE)local S,T,aL=aD(al[7],al[8],al[9],aE)aH[#aH+1]={e,f,aJ,g,h,aK,S,T,aL}aH[#aH][10]=al[10]aH[#aH][11]=al[11]aH[#aH][12]=al[12]aH[#aH][13]=al[13]aH[#aH][14]=al[14]end;return aH end;local function aO(aP,ae)local aQ=ae[1]local aR=ae[2]local aS=ae[3]for c=1,#aP do local aT=aP[c]local aU=aT[1]local aV=aT[2]local aW=aT[3]local aX=aU and aU-aQ or 0;local aY=aV and aV-aR or 0;local aZ=aW and aW-aS or 0;aT[9]=aX*aX+aY*aY+aZ*aZ end;a5(aP,function(j,I)return j[9]>I[9]end)end;function loadModel(a_)local b0=fs.open(a_,"r")if not b0 then error("Could not find model for an object at path: "..a_)end;content=b0.readAll()b0.close()return textutils.unserialise(content)end;local b1=math.pi;local ar=math.sin;local as=math.cos;local b2=math.tan;local at=math.atan;local a4=math.sqrt;function newFrame(e,f,g,h)local r,b3=term.getSize()if e and g then r=g-e+1 end;if f and h then b3=h-f+1 end;local e=e or 1;local f=f or 1;local g=g or r-e+1;local h=h or b3-f+1;local b4={camera={0.000001,0.000001,0.000001,nil,0,0},buffer=newBuffer(e,f,g,h),x1=e,y1=f,x2=g,y2=h,width=r,height=b3,blittleOn=false,pixelratio=1.5}b4.FoV=90;b4.camera[7]=aq(b4.FoV)b4.t=math.tan(math.rad(b4.FoV/2))*2*0.0001;function b4:setBackgroundColor(B)local b5=self.buffer;b5.backgroundColor=B;b5:fastClear()end;function b4:setSize(e,f,g,h)self.x1=e;self.y1=f;self.x2=g;self.y2=h;if not self.blittleOn then self.buffer:setBufferSize(e,f,g,h)self.width=g-e+1;self.height=h-f+1;self.pixelratio=1.5 else self.width=(g-e+1)*2;self.height=(h-f+1)*3;self.pixelratio=1;self.buffer:setBufferSize(e,f,e+self.width-1,f+self.height-1)end;self:updateMappingConstants()end;function b4:highResMode(a2)self.blittleOn=a2;self.buffer:highResMode(a2)if a2 then self.width=(self.x2-self.x1+1)*2;self.height=(self.y2-self.y1+1)*3;self.buffer:setBufferSize(self.x1,self.y1,self.x1+self.width-1,self.y1+self.height-1)self.pixelratio=1 else self.buffer:setBufferSize(self.x1,self.y1,self.x2,self.y2)self.width=self.x2-self.x1+1;self.height=self.y2-self.y1+1;self.pixelratio=1.5 end;self:updateMappingConstants()end;function b4:loadModelRaw(aG)local b6={}local b7=0;for c=1,#aG do local al=aG[c]b6[#b6+1]={}b6[#b6][1]=al.x1;b6[#b6][2]=al.y1;b6[#b6][3]=al.z1;b6[#b6][4]=al.x2;b6[#b6][5]=al.y2;b6[#b6][6]=al.z2;b6[#b6][7]=al.x3;b6[#b6][8]=al.y3;b6[#b6][9]=al.z3;b6[#b6][10]=al.forceRender;b6[#b6][11]=al.c;b6[#b6][12]=al.char;b6[#b6][13]=al.charc;b6[#b6][14]=al.outlineColor;b6[#b6][15]=c;local b8=a4(al.x1*al.x1+al.y1*al.y1+al.z1*al.z1)local b9=a4(al.x2*al.x2+al.y2*al.y2+al.z2*al.z2)local ba=a4(al.x3*al.x3+al.y3*al.y3+al.z3*al.z3)if b8>b7 then b7=b8 end;if b9>b7 then b7=b9 end;if ba>b7 then b7=ba end end;return b6,b7 end;function b4:updateMappingConstants()self.renderOffsetX=m(self.width*0.5)+1;self.renderOffsetY=m(self.height*0.5)self.sXFactor=0.0001*self.width/self.t;self.sYFactor=-0.0001*self.width/(self.t*self.height*self.pixelratio)*self.height end;function b4:map3dTo2d(v,t,aw)local ae=self.camera;local bb=ar(ae[4]or 0)local bc=as(ae[4]or 0)local bd=ar(-ae[5])local be=as(-ae[5])local bf=ar(ae[6])local bg=as(ae[6])local aX=v-ae[1]local aY=t-ae[2]local aZ=aw-ae[3]local bh=be*aX-bd*aZ;aZ=bd*aX+be*aZ;aX=bh;local bi=bg*aY-bf*aX;aX=bf*aY+bg*aX;aY=bi;if bb~=0 then local bj=bb*aZ-bc*aY;aY=bc*aZ+bb*aY;aZ=bj end;local bk=aZ/aX*self.sXFactor+self.renderOffsetX;local bl=aY/aX*self.sYFactor+self.renderOffsetY;return bk,bl,aX>=0.0001 end;function b4:drawObject(aT,ae,bm)local aU=aT[1]local aV=aT[2]local aW=aT[3]local bb=bm[1]local bc=bm[2]local bd=bm[3]local be=bm[4]local bf=bm[5]local bg=bm[6]local bn=aU and aU-ae[1]or 0;local bo=aV and aV-ae[2]or 0;local bp=aW and aW-ae[3]or 0;local aG=aT[7]if#aG<=0 then return end;local bq=aT[8]local aX=bn;local aY=bo;local aZ=bp;local bh=be*aX-bd*aZ;local aZ=bd*aX+be*aZ;local aX=bh;local aX=bf*aY+bg*aX;if aX<-bq then return end;local br=0.5*ae[7]local bs=ar(br)local bt=as(br)if(aX+bq)*bs+(aZ+bq)*bt<0 then return end;if(aX+bq)*bs-(aZ-bq)*bt<0 then return end;local bu=aT[5]if bu and bu~=0 then aG=aM(aG,bu)end;local bv=aT[6]if bv and bv~=0 then aG=aN(aG,bv)end;local bw=aT[4]if bw and bw~=0 then aG=aF(aG,bw)end;aa(aG,aU,aV,aW,ae)local bx=bn*bn+bo*bo+bp*bp<bq*bq*4;local by=self.renderOffsetX;local bz=self.renderOffsetY;local bA=self.sXFactor;local bB=self.sYFactor;local bb=bb;local bc=bc;local bd=bd;local be=be;local bf=bf;local bg=bg;local bn=bn;local bo=bo;local bp=bp;local function bC(v,t,aw)local aX=v+bn;local aY=t+bo;local aZ=aw+bp;local bh=be*aX-bd*aZ;aZ=bd*aX+be*aZ;aX=bh;local bi=bg*aY-bf*aX;aX=bf*aY+bg*aX;aY=bi;local bk=aZ/aX*bA+by;local bl=aY/aX*bB+bz;return bk,bl,aX,aY,aZ end;local function map3dTo2d(v,t,aw)local aX=v+bn;local aY=t+bo;local aZ=aw+bp;local bh=be*aX-bd*aZ;aZ=bd*aX+be*aZ;aX=bh;local bi=bg*aY-bf*aX;aX=bf*aY+bg*aX;aY=bi;local bk=aZ/aX*bA+by;local bl=aY/aX*bB+bz;return bk,bl,aX end;if bb~=0 then function bC(v,t,aw)local aX=v+bn;local aY=t+bo;local aZ=aw+bp;local bh=be*aX-bd*aZ;aZ=bd*aX+be*aZ;aX=bh;local bi=bg*aY-bf*aX;aX=bf*aY+bg*aX;aY=bi;local bj=bb*aZ-bc*aY;aY=bc*aZ+bb*aY;aZ=bj;local bk=aZ/aX*bA+by;local bl=aY/aX*bB+bz;return bk,bl,aX,aY,aZ end;function map3dTo2d(v,t,aw)local aX=v+bn;local aY=t+bo;local aZ=aw+bp;local bh=be*aX-bd*aZ;aZ=bd*aX+be*aZ;aX=bh;local bi=bg*aY-bf*aX;aX=bf*aY+bg*aX;aY=bi;local bj=bb*aZ-bc*aY;aY=bc*aZ+bb*aY;aZ=bj;local bk=aZ/aX*bA+by;local bl=aY/aX*bB+bz;return bk,bl,aX end end;local bD=aG;local b5=self.buffer;for c=1,#bD do local al=bD[c]local e,f,bE=map3dTo2d(al[1],al[2],al[3])if bE>0.00010000001 then local g,h,bh=map3dTo2d(al[4],al[5],al[6])if bh>0.00010000001 then local S,T,bF=map3dTo2d(al[7],al[8],al[9])if bF>0.00010000001 then if al[10]or(g-e)*(T-h)-(h-f)*(S-g)<0 then b5:drawTriangle(e,f,g,h,S,T,al[11],al[12],al[13],al[14])end elseif bx then local e,f,bE,bG,bH=bC(al[1],al[2],al[3])local g,h,bh,bi,bj=bC(al[4],al[5],al[6])local S,T,bF,bI,bJ=bC(al[7],al[8],al[9])local bK=math.abs;local bL=bK(bF-0.0001)local bM=bK(bE-0.0001)local bN=bM+bL;local bO=(bJ*bM+bH*bL)/bN;local bP=(bI*bM+bG*bL)/bN;local by,bA,bz,bB=by,bA,bz,bB;local bQ=bO*10000*bA+by;local bR=bP*10000*bB+bz;if al[10]or(g-e)*(bR-h)-(h-f)*(bQ-g)<0 then b5:drawTriangle(e,f,g,h,bQ,bR,al[11],al[12],al[13],al[14])local bS=bK(bh-0.0001)local bN=bS+bL;local bO=(bj*bL+bJ*bS)/bN;local bP=(bi*bL+bI*bS)/bN;local bT=bO*10000*bA+by;local bU=bP*10000*bB+bz;b5:drawTriangle(bT,bU,g,h,bQ,bR,al[11],al[12],al[13],al[14])end end elseif bx then local e,f,bE,bG,bH=bC(al[1],al[2],al[3])local g,h,bh,bi,bj=bC(al[4],al[5],al[6])local S,T,bF,bI,bJ=bC(al[7],al[8],al[9])local bK=math.abs;if bF>0.00010000001 then local bS=bK(bh-0.0001)local bM=bK(bE-0.0001)local bN=bM+bS;local bO=(bj*bM+bH*bS)/bN;local bP=(bi*bM+bG*bS)/bN;local by,bA,bz,bB=by,bA,bz,bB;local bQ=bO*10000*bA+by;local bR=bP*10000*bB+bz;if al[10]or(bQ-e)*(T-bR)-(bR-f)*(S-bQ)<0 then b5:drawTriangle(e,f,bQ,bR,S,T,al[11],al[12],al[13],al[14])local bL=bK(bF-0.0001)local bN=bS+bL;local bO=(bj*bL+bJ*bS)/bN;local bP=(bi*bL+bI*bS)/bN;local bT=bO*10000*bA+by;local bU=bP*10000*bB+bz;b5:drawTriangle(bT,bU,bQ,bR,S,T,al[11],al[12],al[13],al[14])end else local bM=bK(bE-0.0001)local bS=bK(bh-0.0001)local bL=bK(bF-0.0001)local bV=bM+bS;local bW=bM+bL;local bO=(bH*bS+bj*bM)/bV;local bP=(bG*bS+bi*bM)/bV;local by,bA,bz,bB=by,bA,bz,bB;local bQ=bO*10000*bA+by;local bR=bP*10000*bB+bz;local bX=(bH*bL+bJ*bM)/bW;local bY=(bG*bL+bI*bM)/bW;local bT=bX*10000*bA+by;local bU=bY*10000*bB+bz;if al[10]or(bQ-e)*(bU-bR)-(bR-f)*(bT-bQ)<0 then b5:drawTriangle(e,f,bQ,bR,bT,bU,al[11],al[12],al[13],al[14])end end end elseif bx then local e,f,bE,bG,bH=bC(al[1],al[2],al[3])local g,h,bh,bi,bj=bC(al[4],al[5],al[6])local S,T,bF,bI,bJ=bC(al[7],al[8],al[9])local bK=math.abs;if bh>0.00010000001 then if bF>0.00010000001 then local bM=bK(bE-0.0001)local bS=bK(bh-0.0001)local bN=bM+bS;local bO=(bH*bS+bj*bM)/bN;local bP=(bG*bS+bi*bM)/bN;local by,bA,bz,bB=by,bA,bz,bB;local bQ=bO*10000*bA+by;local bR=bP*10000*bB+bz;if al[10]or(g-bQ)*(T-h)-(h-bR)*(S-g)<0 then b5:drawTriangle(bQ,bR,g,h,S,T,al[11],al[12],al[13],al[14])local bL=bK(bF-0.0001)local bN=bM+bL;local bO=(bH*bL+bJ*bM)/bN;local bP=(bG*bL+bI*bM)/bN;local bT=bO*10000*bA+by;local bU=bP*10000*bB+bz;b5:drawTriangle(bQ,bR,bT,bU,S,T,al[11],al[12],al[13],al[14])end else local bM=bK(bE-0.0001)local bS=bK(bh-0.0001)local bL=bK(bF-0.0001)local bV=bS+bM;local bW=bS+bL;local bO=(bH*bS+bj*bM)/bV;local bP=(bG*bS+bi*bM)/bV;local by,bA,bz,bB=by,bA,bz,bB;local bQ=bO*10000*bA+by;local bR=bP*10000*bB+bz;local bX=(bj*bL+bJ*bS)/bW;local bY=(bi*bL+bI*bS)/bW;local bT=bX*10000*bA+by;local bU=bY*10000*bB+bz;if al[10]or(g-bQ)*(bU-h)-(h-bR)*(bT-g)<0 then b5:drawTriangle(bQ,bR,g,h,bT,bU,al[11],al[12],al[13],al[14])end end else if bF>0.00010000001 then local bM=bK(bE-0.0001)local bS=bK(bh-0.0001)local bL=bK(bF-0.0001)local bV=bL+bM;local bW=bL+bS;local bO=(bH*bL+bJ*bM)/bV;local bP=(bG*bL+bI*bM)/bV;local by,bA,bz,bB=by,bA,bz,bB;local bQ=bO*10000*bA+by;local bR=bP*10000*bB+bz;local bX=(bj*bL+bJ*bS)/bW;local bY=(bi*bL+bI*bS)/bW;local bT=bX*10000*bA+by;local bU=bY*10000*bB+bz;if al[10]or(bT-bQ)*(T-bU)-(bU-bR)*(S-bT)<0 then b5:drawTriangle(bQ,bR,bT,bU,S,T,al[11],al[12],al[13],al[14])end end end end end end;function b4:drawObjects(aP)local ae=self.camera;local bm={ar(ae[4]or 0),as(ae[4]or 0),ar(-ae[5]),as(-ae[5]),ar(ae[6]),as(ae[6])}aO(aP,ae)local aP=aP;for c=1,#aP do self:drawObject(aP[c],ae,bm)end end;function b4:drawBuffer()local b5=self.buffer;b5:drawBuffer()b5:fastClear()end;function b4:setCamera(bZ,b_,c0,bw,bu,bv)local aq=math.rad;if type(bZ)=="table"then local ae=bZ;self.camera={ae.x or self.camera[1]or 0,ae.y or self.camera[2]or 0,ae.z or self.camera[3]or 0,ae.rotX and aq(ae.rotX+90)or self.camera[4]or 0,ae.rotY and aq(ae.rotY)or self.camera[5]or 0,ae.rotZ and aq(ae.rotZ)or self.camera[6]or 0,self.camera[7]}else self.camera={bZ or self.camera[1]or 0,b_ or self.camera[2]or 0,c0 or self.camera[3]or 0,bw and aq(bw+90)or self.camera[4]or 0,bu and aq(bu)or self.camera[5]or 0,bv and aq(bv)or self.camera[6]or 0,self.camera[7]}end;if self.camera[4]==math.pi*0.5 then self.camera[4]=nil end end;function b4:setFoV(br)self.FoV=br or 90;self.t=math.tan(math.rad(self.FoV/2))*2*0.0001;self:updateMappingConstants()self.camera[7]=aq(self.FoV)end;function b4:setWireFrame(a2)self.buffer:useTriangleEdges(a2)end;function b4:getObjectIndexTrace(aP,v,t)local function c1(c2,c3,c4)return(c2.x-c4.x)*(c3.y-c4.y)-(c3.x-c4.x)*(c2.y-c4.y)end;local function c5(c6,c7,e,f,g,h,S,T,c8,c9,ca,cb)local M=c1({x=c6,y=c7},{x=e,y=f},{x=g,y=h})<0;local O=c1({x=c6,y=c7},{x=g,y=h},{x=S,y=T})<0;local W=c1({x=c6,y=c7},{x=S,y=T},{x=e,y=f})<0;return M==O and O==W end;local t=t-1;local cc={}if self.blittleOn then v=v*2;t=t*3+1 end;local ae=self.camera;local bm={ar(ae[4]or 0),as(ae[4]or 0),ar(-ae[5]),as(-ae[5]),ar(ae[6]),as(ae[6])}local bb=bm[1]local bc=bm[2]local bd=bm[3]local be=bm[4]local bf=bm[5]local bg=bm[6]for c=1,#aP do local aT=aP[c]local aG=aT[7]local aH=aT[5]and aT[5]~=0 and rotateModel(aG,aT[5])or aG;local aU=aT[1]local aV=aT[2]local aW=aT[3]local by=self.renderOffsetX;local bz=self.renderOffsetY;local bA=self.sXFactor;local bB=self.sYFactor;local bb=bb;local bc=bc;local bd=bd;local be=be;local bf=bf;local bg=bg;local bn=aU-ae[1]local bo=aV-ae[2]local bp=aW-ae[3]function map3dTo2d(v,t,aw)local aX=v+bn;local aY=t+bo;local aZ=aw+bp;local bh=be*aX-bd*aZ;aZ=bd*aX+be*aZ;aX=bh;local bi=bg*aY-bf*aX;aX=bf*aY+bg*aX;aY=bi;if bb~=0 then local bj=bb*aZ-bc*aY;aY=bc*aZ+bb*aY;aZ=bj end;local bk=aZ/aX*bA+by;local bl=aY/aX*bB+bz;return bk,bl,aX>0 end;for cd=1,#aH do local al=aH[cd]local e,f,ce=map3dTo2d(al[1],al[2],al[3])if ce then local g,h,cf=map3dTo2d(al[4],al[5],al[6])if cf then local S,T,cg=map3dTo2d(al[7],al[8],al[9])if cg then if al[10]or(g-e)*(T-h)-(h-f)*(S-g)<0 then if not self.blittleOn then if c5(v,t,e,f,g,h,S,T,self.x1,self.y1,self.x2,self.y2)then cc[#cc+1]={objectIndex=c,polygonIndex=al[15]}end else if c5(v,t,e,f,g,h,S,T,(self.x2-1)*2+1,(self.y1-1)*3+1,self.x2*2,(self.y2+1)*3)then cc[#cc+1]={objectIndex=c,polygonIndex=al[15]}end end end end end end end end;if#cc<=0 then return elseif#cc==1 then return cc[1].objectIndex,cc[1].polygonIndex end;local ch={}local ci=-1;local cj=math.huge;for c=1,#cc do local aT=aP[cc[c].objectIndex]local aX=ae[1]-aT[1]local aY=ae[2]-aT[2]local aZ=ae[3]-aT[3]local ck=a4(aX*aX+aY*aY+aZ*aZ)if ck<cj then cj=ck;ci=cc[c].objectIndex end end;for c=1,#cc do local aT=aP[cc[c].objectIndex]local aX=ae[1]-aT[1]local aY=ae[2]-aT[2]local aZ=ae[3]-aT[3]local ck=a4(aX*aX+aY*aY+aZ*aZ)if ck==cj then ch[#ch+1]=cc[c].polygonIndex end end;local aT=aP[ci]local aG=aT[7]local cl=-1;local cm=math.huge;local ai=aT[1]-ae[1]local aj=aT[2]-ae[2]local ak=aT[3]-ae[3]local bD={}for c=1,#ch do local cn=ch[c]local al=aG[cn]local am=ai+(al[1]+al[4]+al[7])/3;local an=aj+(al[2]+al[5]+al[8])/3;local ao=ak+(al[3]+al[6]+al[9])/3;local ck=a4(am*am+an*an+ao*ao)if ck<cm then cm=ck;cl=ch[c]end end;return ci,cl end;function b4:newObject(co,v,t,aw,bw,bu,bv)local aG=nil;local bq=nil;if type(co)=="table"then aG,bq=self:loadModelRaw(co)else local cp=loadModel(co)aG,bq=self:loadModelRaw(cp)end;local aT={v,t,aw,bw,bu,bv,aG,bq}aT.frame=self;function aT:setPos(v,t,aw)self[1]=v or self[1]self[2]=t or self[2]self[3]=aw or self[3]end;function aT:setRot(bw,bu,bv)self[4]=bw or self[4]self[5]=bu or self[5]self[6]=bv or self[6]end;function aT:setModel(co)if type(co)=="table"then aG,bq=self.frame:loadModelRaw(co)self[7]=aG;self[8]=bq else local cp=loadModel(co)aG,bq=self.frame:loadModelRaw(cp)self[7]=aG;self[8]=bq end end;return aT end;b4:updateMappingConstants()b4:highResMode(true)return b4 end;local cq={}function newPoly(e,f,aJ,g,h,aK,S,T,aL,B)return{x1=e,y1=f,z1=aJ,x2=g,y2=h,z2=aK,x3=S,y3=T,z3=aL,c=B}end;function cq:cube(cr)cr.color=cr.color or colors.red;return{newPoly(-.5,-.5,-.5,.5,-.5,.5,-.5,-.5,.5,cr.bottom or cr.color),newPoly(-.5,-.5,-.5,.5,-.5,-.5,.5,-.5,.5,cr.bottom2 or cr.bottom or cr.color),newPoly(-.5,.5,-.5,-.5,.5,.5,.5,.5,.5,cr.top or cr.color),newPoly(-.5,.5,-.5,.5,.5,.5,.5,.5,-.5,cr.top or cr.color),newPoly(-.5,-.5,-.5,-.5,-.5,.5,-.5,.5,-.5,cr.side or cr.color),newPoly(-.5,-.5,.5,-.5,.5,.5,-.5,.5,-.5,cr.side2 or cr.side or cr.color),newPoly(.5,-.5,-.5,.5,.5,.5,.5,-.5,.5,cr.side or cr.color),newPoly(.5,-.5,-.5,.5,.5,-.5,.5,.5,.5,cr.side2 or cr.side or cr.color),newPoly(-.5,-.5,-.5,.5,.5,-.5,.5,-.5,-.5,cr.side or cr.color),newPoly(-.5,-.5,-.5,-.5,.5,-.5,.5,.5,-.5,cr.side2 or cr.side or cr.color),newPoly(-.5,-.5,.5,.5,-.5,.5,-.5,.5,.5,cr.side or cr.color),newPoly(.5,-.5,.5,.5,.5,.5,-.5,.5,.5,cr.side2 or cr.side or cr.color)}end;function cq:sphere(cr)cr.res=cr.res or 32;cr.color=cr.color or colors.red;local cs=1/cr.res;local aG={}local ct={}for c=0,cr.res do local t=0.5*as(c/cr.res*b1)local cu={}for cd=0,cr.res do local cv=0.5*a4(1-t*2*t*2)local v=as(cd/cr.res*b1*2)*cv;local aw=ar(cd/cr.res*b1*2)*cv;local g=as((cd+1)/cr.res*b1*2)*cv;local aK=ar((cd+1)/cr.res*b1*2)*cv;if ct[cd]then aG[#aG+1]={x1=ct[(cd+1)%cr.res].x,y1=ct[(cd+1)%cr.res].y,z1=ct[(cd+1)%cr.res].z,x2=v,y2=t,z2=aw,x3=ct[cd].x,y3=ct[cd].y,z3=ct[cd].z,c=cr.color}aG[#aG+1]={x1=g,y1=t,z1=aK,x2=v,y2=t,z2=aw,x3=ct[(cd+1)%cr.res].x,y3=ct[(cd+1)%cr.res].y,z3=ct[(cd+1)%cr.res].z,c=cr.color2 or cr.color}end;cu[cd]={x=v,y=t,z=aw}end;ct=cu end;if cr.colors or cr.top or cr.bottom then for c=1,#aG do local cw=aG[c]local an=(cw.y1+cw.y2+cw.y3)/3;if cr.colors then local cx=m((-an+0.5)*#cr.colors+1)cw.c=cr.colors[cx]or cw.c else if an>=0 then cw.c=cr.top or cw.c else cw.c=cr.bottom or cw.c end end end end;return aG end;function cq:icosphere(cr)cr.res=cr.res or 1;local cy=(1+a4(5))/2;local cz={{cy,1,0},{cy,-1,0},{-cy,-1,0},{-cy,1,0},{1,0,cy},{-1,0,cy},{-1,0,-cy},{1,0,-cy},{0,cy,1},{0,cy,-1},{0,-cy,-1},{0,-cy,1}}function buildPoly(cA,cB,cC)return newPoly(cz[cA][1],cz[cA][2],cz[cA][3],cz[cB][1],cz[cB][2],cz[cB][3],cz[cC][1],cz[cC][2],cz[cC][3],cr.colors and 1 or cr.color)end;local aG={buildPoly(11,2,12),buildPoly(11,8,2),buildPoly(11,7,8),buildPoly(11,3,7),buildPoly(11,12,3),buildPoly(4,7,3),buildPoly(4,10,7),buildPoly(4,9,10),buildPoly(4,6,9),buildPoly(4,3,6),buildPoly(5,6,12),buildPoly(5,9,6),buildPoly(5,1,9),buildPoly(5,2,1),buildPoly(5,12,2),buildPoly(3,12,6),buildPoly(1,8,10),buildPoly(1,10,9),buildPoly(1,2,8),buildPoly(10,8,7)}function subdivide()local cD={}for c=1,#aG do local cw=aG[c]local cE={x=(cw.x1+cw.x2)/2,y=(cw.y1+cw.y2)/2,z=(cw.z1+cw.z2)/2}local cF={x=(cw.x1+cw.x3)/2,y=(cw.y1+cw.y3)/2,z=(cw.z1+cw.z3)/2}local cG={x=(cw.x2+cw.x3)/2,y=(cw.y2+cw.y3)/2,z=(cw.z2+cw.z3)/2}local cH=cw.c;if cr.colorsFractal then cH=cH%#cr.colors+1 end;cD[#cD+1]=newPoly(cE.x,cE.y,cE.z,cG.x,cG.y,cG.z,cF.x,cF.y,cF.z,cw.c)cD[#cD+1]=newPoly(cw.x1,cw.y1,cw.z1,cE.x,cE.y,cE.z,cF.x,cF.y,cF.z,cH)cD[#cD+1]=newPoly(cE.x,cE.y,cE.z,cw.x2,cw.y2,cw.z2,cG.x,cG.y,cG.z,cH)cD[#cD+1]=newPoly(cF.x,cF.y,cF.z,cG.x,cG.y,cG.z,cw.x3,cw.y3,cw.z3,cH)end;aG=cD end;for c=1,cr.res-1 do subdivide()end;function forceLength(v,t,aw)local cI=math.sqrt(v*v+t*t+aw*aw)local cJ=0.5/cI;return v*cJ,t*cJ,aw*cJ end;for c=1,#aG do local cw=aG[c]cw.x1,cw.y1,cw.z1=forceLength(cw.x1,cw.y1,cw.z1)cw.x2,cw.y2,cw.z2=forceLength(cw.x2,cw.y2,cw.z2)cw.x3,cw.y3,cw.z3=forceLength(cw.x3,cw.y3,cw.z3)if not cr.colorsFractal then local an=(cw.y1+cw.y2+cw.y3)/3;if cr.colors then local cx=math.floor((-an+0.5)*#cr.colors+1)cw.c=cr.colors[cx]or cw.c else if an>=0 then cw.c=cr.top or cw.c else cw.c=cr.bottom or cw.c end end else cw.c=cr.colors[cw.c]end end;return aG end;function cq:plane(cr)cr.color=cr.color or colors.lime;cr.size=cr.size or 1;cr.y=cr.y or 0;return{newPoly(-1*cr.size,cr.y,1*cr.size,1*cr.size,cr.y,-1*cr.size,-1*cr.size,cr.y,-1*cr.size,cr.color),newPoly(-1*cr.size,cr.y,1*cr.size,1*cr.size,cr.y,1*cr.size,1*cr.size,cr.y,-1*cr.size,cr.color)}end;function cq:mountains(cr)cr.res=cr.res or 20;cr.randomOffset=cr.randomOffset or 0;cr.height=cr.height or 1;cr.randomHeight=cr.randomHeight or 0;cr.y=cr.y or 0;cr.scale=cr.scale or 100;cr.color=cr.color or colors.green;cr.snowColor=cr.snowColor or colors.white;local cK=3/cr.res*cr.height/(cr.randomHeight+1)local cL=3/cr.res*cr.height*(cr.randomHeight+1)local aG={}for c=0,cr.res do local cM=math.random(-cr.randomOffset*100,cr.randomOffset*100)/100;local cN=c+cM;local e=as((cN-1)/cr.res*b1*2)*cr.scale;local aJ=ar((cN-1)/cr.res*b1*2)*cr.scale;local g=as((cN-0.5)/cr.res*b1*2)*cr.scale;local aK=ar((cN-0.5)/cr.res*b1*2)*cr.scale;local S=as(cN/cr.res*b1*2)*cr.scale;local aL=ar(cN/cr.res*b1*2)*cr.scale;local cO=math.random(cK*100,cL*100)/100*cr.scale;local al={x1=e,y1=cr.y,z1=aJ,x2=S,y2=cr.y,z2=aL,x3=g,y3=cr.y+cO,z3=aK,c=cr.color,forceRender=true}aG[#aG+1]=al;if cr.snow then local cP=0.93;local cQ=cr.snowHeight or 0.5;local cR=1-cQ*cL/(cO/cr.scale)cR=l(0,k(1,cR))if cR>0.2 then local cS={x1=(e*cR+g*(1-cR))*cP,y1=cr.y+cO*(1-cR),z1=(aJ*cR+aK*(1-cR))*cP,x2=(S*cR+g*(1-cR))*cP,y2=cr.y+cO*(1-cR),z2=(aL*cR+aK*(1-cR))*cP,x3=g*cP,y3=cr.y+cO,z3=aK*cP,c=cr.snowColor,forceRender=true}aG[#aG+1]=cS end end end;return aG end;local cT={}function cT:invertTriangles(aG)if not aG or type(aG)~="table"then error("transforms:invertTriangles expected arg#1 to be a table (model)")end;local cD={}for c=1,#aG do local cU=aG[c]local cV={x1=cU.x1,y1=cU.y1,z1=cU.z1,x2=cU.x3,y2=cU.y3,z2=cU.z3,x3=cU.x2,y3=cU.y2,z3=cU.z2,c=cU.c,char=cU.char,charc=cU.charc,forceRender=cU.forceRender,outlineColor=cU.outlineColor}cD[c]=cV end;return cD end;function cT:setOutline(aG,cr)if not aG or type(aG)~="table"then error("transforms:invertTriangles expected arg#1 to be a table (model)")end;for c=1,#aG do local cU=aG[c]if type(cr)=="table"then cU.outlineColor=cr[cU.c]or cU.outlineColor else cU.outlineColor=cr end end;return aG end;return{newFrame=newFrame,loadModel=loadModel,newBuffer=newBuffer,linear=linear,models=cq,transforms=cT}