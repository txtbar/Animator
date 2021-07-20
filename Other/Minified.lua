if getgenv()["Animator"]==nil then local a=game:GetService("HttpService")local b=false;local c={}c.__index=c;c.ClassName="Signal"function c.new()local self=setmetatable({},c)self._bindableEvent=Instance.new("BindableEvent")self._argMap={}self._source=b and debug.traceback()or""self._bindableEvent.Event:Connect(function(d)self._argMap[d]=nil;if not self._bindableEvent and not next(self._argMap)then self._argMap=nil end end)return self end;function c:Fire(...)if not self._bindableEvent then warn(("Signal is already destroyed. %s"):format(self._source))return end;local e=table.pack(...)local d=a:GenerateGUID(false)self._argMap[d]=e;self._bindableEvent:Fire(d)end;function c:Connect(f)if not(type(f)=="function")then error(("connect(%s)"):format(typeof(f)),2)end;return self._bindableEvent.Event:Connect(function(d)local e=self._argMap[d]if e then f(table.unpack(e,1,e.n))else error("Missing arg data, probably due to reentrance.")end end)end;function c:Wait()local d=self._bindableEvent.Event:Wait()local e=self._argMap[d]if e then return table.unpack(e,1,e.n)else error("Missing arg data, probably due to reentrance.")return nil end end;function c:Destroy()if self._bindableEvent then self._bindableEvent:Destroy()self._bindableEvent=nil end;setmetatable(self,nil)end;local g={}local h=string.format;function g:sendNotif(i,j,k,l,m,n)game:GetService("StarterGui"):SetCore("SendNotification",{Title="Animator",Text=i.."\nBy hayper#0001"or nil,Icon=j or nil,Duration=k or nil,Button1=l or nil,Button2=m or nil,Callback=n or nil})end;function g:convertEnum(o)local p=tostring(o):split(".")if p[1]=="Enum"then local q=p[2]local r=p[3]local s={["PoseEasingDirection"]="EasingDirection",["PoseEasingStyle"]="EasingStyle"}if s[q]then return Enum[s[q]][r]else return o end else return o end end;function g:getMotors(t,u)u=u or{}if not t:IsA("Player")then error(h("invalid argument 1 to 'getMotors' (Player expected, got %s)",t.ClassName))end;if typeof(u)~="table"then error(h("invalid argument 1 to 'getMotors' (Table expected, got %s)",typeof(u)))end;local v={}for w,x in next,t.Character:GetDescendants()do if x:IsA("Motor6D")and x.Part0~=nil and x.Part1~=nil then local y=false;for w,z in next,u do if typeof(z)=="Instance"then if x:IsDescendantOf(z)then y=true;break end end end;if y~=true then table.insert(v,x)end end end;return v end;local A={}function A:parsePoseData(B)if not B:IsA("Pose")then error(h("invalid argument 1 to '_parsePoseData' (Pose expected, got %s)",B.ClassName))end;local C={Name=B.Name,CFrame=B.CFrame,EasingDirection=g:convertEnum(B.EasingDirection),EasingStyle=g:convertEnum(B.EasingStyle),Weight=B.Weight}if#B:GetChildren()>0 then C.Subpose={}for w,q in next,B:GetChildren()do if q:IsA("Pose")then table.insert(C.Subpose,A:parsePoseData(q))end end end;return C end;function A:parseKeyframeData(D)if not D:IsA("Keyframe")then error(h("invalid argument 1 to '_parseKeyframeData' (Keyframe expected, got %s)",D.ClassName))end;local E={Name=D.Name,Time=D.Time,Pose={}}for w,q in next,D:GetChildren()do if q:IsA("Pose")then table.insert(E.Pose,A:parsePoseData(q))elseif q:IsA("KeyframeMarker")then if not E.Marker then E.Marker={}end;if not E.Marker[q.Name]then E.Marker[q.Name]={}end;table.insert(E.Marker,q.Name)end end;return E end;function A:parseAnimationData(F)if not F:IsA("KeyframeSequence")then error(h("invalid argument 1 to 'parseAnimationData' (KeyframeSequence expected, got %s)",F.ClassName))end;local G={Loop=F.Loop,Priority=F.Priority,Frames={}}for w,H in next,F:GetChildren()do if H:IsA("Keyframe")then table.insert(G.Frames,A:parseKeyframeData(H))end end;table.sort(G.Frames,function(I,J)return I.Time<J.Time end)return G end;local K=game:GetService("RunService")local L=game:GetService("TweenService")local M={AnimationData={},Player=nil,Looped=false,Length=0,Speed=1,IsPlaying=false,_stopFadeTime=0.100000001,_motorIgnoreList={},_playing=false,_stopped=false,_isLooping=false,_markerSignal={}}M.__index=M;function M.new(t,N)if not t:IsA("Player")then error(h("invalid argument 1 to 'new' (Player expected, got %s)",t.ClassName))end;local O=setmetatable({},M)O.Player=t;if typeof(N)=="string"or typeof(N)=="number"then local P=game:GetObjects("rbxassetid://"..tostring(N))[1]if not P:IsA("KeyframeSequence")then error("invalid argument 1 to 'new' (AnimationID expected)")end;O.AnimationData=A:parseAnimationData(P)elseif typeof(N)=="table"then O.AnimationData=N elseif typeof(N)=="Instance"and N:IsA("KeyframeSequence")then O.AnimationData=A:parseAnimationData(N)elseif typeof(N)=="Instance"and N:IsA("Animation")then local P=game:GetObjects(N.AnimationId)[1]if not P:IsA("KeyframeSequence")then error("invalid argument 1 to 'new' (AnimationID inside Animation expected)")end;O.AnimationData=A:parseAnimationData(P)else error(h("invalid argument 2 to 'new' (number,string,KeyframeSequence expected, got %s)",t.ClassName))end;O.Looped=O.AnimationData.Loop;O.Length=O.AnimationData.Frames[#O.AnimationData.Frames].Time;O.DidLoop=c.new()O.Stopped=c.new()O.KeyframeReached=c.new()return O end;function M:_playPose(B,Q,R)local S=g:getMotors(self.Player,self._motorIgnoreList)if B.Subpose then for w,T in next,B.Subpose do self:_playPose(T,B,R)end end;if Q then for w,U in next,S do if U.Part0.Name==Q.Name and U.Part1.Name==B.Name then if R>0 then local V=TweenInfo.new(R,B.EasingStyle,B.EasingDirection)if self._stopped~=true then L:Create(U,V,{Transform=B.CFrame}):Play()end else U.Transform=B.CFrame end end end else if self.Player.Character[B.Name]then self.Player.Character[B.Name].CFrame=self.Player.Character[B.Name].CFrame*B.CFrame end end end;function M:IgnoreMotorIn(W)if typeof(W)~="table"then error(h("invalid argument 1 to 'IgnoreMotorIn' (Table expected, got %s)",typeof(W)))end;self._motorIgnoreList=W end;function M:GetMotorIgnoreList()return self._motorIgnoreList end;function M:Play(X,Y,Z)X=X or 0.100000001;if self._playing==false or self._isLooping==true then self._playing=true;self._isLooping=false;self.IsPlaying=true;local _=self.Player.Character;if _:FindFirstChildOfClass("Humanoid")then if _.Humanoid:FindFirstChildOfClass("Animator")then _.Humanoid.Animator:Destroy()end end;local a0;a0=_:GetPropertyChangedSignal("Parent"):Connect(function()if _.Parent==nil then a0:Disconnect()self:Destroy()end end)local a1=os.clock()coroutine.wrap(function()for x,H in next,self.AnimationData.Frames do H.Time=H.Time/self.Speed;if x~=1 and H.Time>os.clock()-a1 then repeat K.RenderStepped:Wait()until os.clock()-a1>H.Time or self._stopped==true end;if self._stopped==true then break end;if H.Name~="Keyframe"then self.KeyframeReached:Fire(H.Name)end;if H["Marker"]then for a2,r in next,H["Marker"]do if self._markerSignal[a2]then self._markerSignal[a2]:Fire(r)end end end;if H.Pose then for w,q in next,H.Pose do X=X+H.Time;if x~=1 then X=(H.Time*self.Speed-self.AnimationData.Frames[x-1].Time)/(Z or self.Speed)end;self:_playPose(q,nil,X)end end end;if self.Looped==true and self._stopped~=true then self.DidLoop:Fire()self._isLooping=true;return self:Play(X,Y,Z)end;K.RenderStepped:Wait()for w,J in next,g:getMotors(self.Player,self._motorIgnoreList)do if self._stopFadeTime>0 then L:Create(J,TweenInfo.new(self._stopFadeTime,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Transform=CFrame.new(),CurrentAngle=0}):Play()else J.CurrentAngle=0;J.Transform=CFrame.new()end end;if _:FindFirstChildOfClass("Humanoid")and not _.Humanoid:FindFirstChildOfClass("Animator")then Instance.new("Animator",_.Humanoid)else self:Destroy()end;a0:Disconnect()self._stopped=false;self._playing=false;self.IsPlaying=false;self.Stopped:Fire()end)()end end;function M:GetTimeOfKeyframe(a3)for w,H in next,self.AnimationData.Frames do if H.Name==a3 then return H.Time end end;return math.huge end;function M:GetMarkerReachedSignal(a4)if not self._markerSignal[a4]then self._markerSignal[a4]=c.new()end;return self._markerSignal[a4]end;function M:AdjustSpeed(Z)self.Speed=Z end;function M:Stop(X)self._stopFadeTime=X or 0.100000001;self._stopped=true end;function M:Destroy()self:Stop(0)self.Stopped:Wait()self.DidLoop:Destroy()self.Stopped:Destroy()self.KeyframeReached:Destroy()for w,a5 in next,self._markerSignal do a5:Destroy()end;self=nil end;local a6=game:GetService("Players")local t=a6.LocalPlayer;getgenv().Animator=M;getgenv().hookAnimatorFunction=function()local a7;a7=hookmetamethod(game,"__namecall",function(a8,...)local a9=getnamecallmethod()if a8.ClassName=="Humanoid"and a8.Parent==t.Character and a9=="LoadAnimation"and checkcaller()then return M.new(t,...)end;return a7(a8,...)end)g:sendNotif("Hook Loaded\nby whited#4382",nil,5)end;g:sendNotif("API Loaded",nil,5)end