#returns hypotenuse of triangle
def hypot(x,y):
	return (x**2+y**2)**0.5
#returns acceleration towards object of mass m with relative position dx,dy with G default to 1
def gravacc(dx,dy,m):
	global G
	r=hypot(dx,dy)
	a=G*m/r**2
	return [a*dx/r,a*dy/r]
def comcalc():
	global P
	com=[0,0]
	totm=0
	for b in range(0,len(P)):
		com[0]+=P[b][0][0]*P[b][2]
		com[1]+=P[b][0][1]*P[b][2]
		totm+=P[b][2]
	com[0]/=totm
	com[1]/=totm
	return com
def gravf(dx,dy,m1,m2):
	global G
	r=hypot(dx,dy)
	f=G*m1*m2/r**2
	return [f*dx/r,f*dy/r]
#returns velocities of 2 particles after collision with e default to 1
def collide(u1,m1,u2,m2,e=1):
	v1=(u1*m1+u2*m2+e*m2*(u2-u1))/(m1+m2)
	v2=(u1*m1+u2*m2+e*m1*(u1-u2))/(m1+m2)
	return [v1,v2]
#merge 2 objects
def merge(b1,b2):
	global P
	nm=P[b1][2]+P[b2][2]
	P[b1][0]=[(P[b1][0][0]*P[b1][2]+P[b2][0][0]*P[b2][2])/nm,(P[b1][0][1]*P[b1][2]+P[b2][0][1]*P[b2][2])/nm]
	P[b1][1]=[(P[b1][1][0]*P[b1][2]+P[b2][1][0]*P[b2][2])/nm,(P[b1][1][1]*P[b1][2]+P[b2][1][1]*P[b2][2])/nm]
	P[b1][3]=getsize(nm)
	P[b1][4]=getcol(nm)
	P[b1][2]=nm
	del P[b2]
	global tb
	if tb>b2:
		tb-=1
	elif tb==b2:
		tb=b1
def getsize(m):
	return log(m)
def getcol(m):
	lg=log(m)
	if m<200:
		r=g=b=70*m**0.2
	elif m<800:
		r=255
		g=-0.375*m+346.247*lg+-1759.525
		b=1.275*m+-367.887*lg+1694.183
	elif m<1600:
		r=g=-0.265*m+-62.196*lg+882.642
		b=255
	else:
		r=g=0
		b=255
	if r<0: r=0
	if g<0: g=0
	if b<0: b=0
	if r>255: r=255
	if g>255: g=255
	if b>255: b=255
	
	return "#%02x%02x%02x" % (r, g, b)
	
#place new object
def lclick(event):
	global mpos
	mpos=[event.x,event.y]
	global nm
	s=getsize(nm)
	w.create_oval(mpos[0]+s,mpos[1]+s,mpos[0]-s,mpos[1]-s,tags='oval',fill='green')
def lmove(event):
	global mpos
	w.delete('line')
	global cx
	global cy
	w.create_line(mpos[0],mpos[1],event.x,event.y,tags='line',fill='green')
def lrelease(event):
	w.delete('line')
	w.delete('oval')
	global mpos
	placeobj(mpos[0]-cx,mpos[1]-cy)
	global P
	global tb
	global G
	b1=len(P)-1
	if tb!=-1:
		rx=P[tb][0][0]-P[b1][0][0]
		ry=P[tb][0][1]-P[b1][0][1]
		r=hypot(rx,ry)
		vc=(G*P[tb][2]/r)**0.5
		unx=-ry/r
		uny=rx/r
		P[b1][1]=[unx*vc+0.01*(event.x-mpos[0])+P[tb][1][0],uny*vc+0.01*(event.y-mpos[1])+P[tb][1][1]]
	else:
		P[b1][1]=[0.01*(event.x-mpos[0])+P[tb][1][0],0.01*(event.y-mpos[1])+P[tb][1][1]]
	
def placeobj(x,y):
	global P
	global nm
	b1=len(P)
	P.append([[float(x),float(y)],[0.0,0.0],float(nm),getsize(nm),getcol(nm)])
#pause/go
def mclick(event):
	global run
	run*=-1
#follow clicked object
def rclick(event):
	item=w.find_overlapping(event.x,event.y,event.x,event.y)
	coords=w.coords(item)
	global tb
	tb=-1
	if coords!=[]:
		#select object clicked on
		tt=tl=0
		global P
		global cx
		global cy
		for b in range(0,len(P)):
			if (P[b][0][0]+P[b][3]+cx==coords[2]) and (P[b][0][1]+P[b][3]+cy==coords[3]):
				tb=b
				break
	print tb
#create circle of randomly placed bodies
def disk(p,d):
	global ux
	global uy
	dx=ux/2.
	dy=uy/2.
	pi=3.141592654
	global G
	global nm
	tv=[0,0]
	tm=p*nm
	for b in range(0,p):
		r=d+1
		while r>d:
			px=2*d*random()-d
			py=2*d*random()-d
			r=hypot(px,py)
		placeobj(dx+px,dy+py)
		#grav field strength at px,py in uniform disk mass tm (irrelevant of where px & py are, as long as r<=d)
		#g=G*tm/d**2
		#equate potential energy (mgr) & kinetic energy (0.5mv^2), find v
		#vc=(2*G*tm*r)**0.5/d
		#or just scale orbital speed by factor of r/d
		vc=((G*p*nm)/r)**0.5*r/d
		unx=py/r
		uny=-px/r
		P[b][1]=[unx*vc,uny*vc]
		tv=[tv[0]+P[b][1][0],tv[1]+P[b][1][1]]
	utv=[tv[0]/p,tv[1]/p]
	for b in range(0,p):
		P[b][1][0]-=utv[0]
		P[b][1][1]-=utv[1]
#TODO once program graphics and main loop working:
	#del list[i] to remove object at i from list
	#list.append(x) to add x to list
#maths stuff
from math import *
#random numbers
from random import random
#module to allow sleep(x) command use
from time import sleep
#allow clock printing
from time import clock
#Tk for grapgics
from Tkinter import *
#create window
root=Tk()
#create canvas
ux=800
uy=500
w=Canvas(width=ux,height=uy,background='black')
w.pack()
#click binding
w.bind("<Button-1>",lclick)
w.bind("<ButtonRelease-1>",lrelease)
w.bind("<B1-Motion>	",lmove)
w.bind("<Button-2>",mclick)
w.bind("<Button-3>",rclick)
mpos=[0,0]
G=0.5
#P is array containing all info about particles
#P[[qx,qy],[vx,vy],m,s,c]
#old 			new
#p[b][0/1]		P[b][0][0/1]
#v[b][0/1]		P[b][1][0/1]
#m[b]			P[b][2]
#s[b]			P[b][3]
#c[b]			P[b][4]
P=[]
#create objects
for b1 in range(0,len(P)):
	#w.create_oval(x1,y1,x2,y2,fill='')
	w.create_oval(0,0,0,0,tags=b1)
#new object mass
nm=10.
disk(300,200)
step=0
print clock()
#camera pos
cx=cy=0.
#selected body
tb=-1
#sim running
run=1
#new gravity force calc
#generate buckets
#P=buckets(P) (ordered list inso pseudo-buckets)
#P2=split(P,10) (list of particles in necessary buckets)
#B=COM of each bucket ([[x0,y0],[x1,y1]...])
	#def split(l, n):
	#	return [l[i:i+n] for i in range(0, len(l), n)]
	#def xcoord(e):
	#	return e[0][0]
	#def ycoord(e):
	#	return e[0][1]
	#necessary for buckets proc
#foreach pair of B:
	#calculate dist between
	#calculate grav force between, apply acceleration to every particle in each bucket
		#possibly if buckets COM close enough do it for between everry particle in those 2 buckets?
#foreach P2:
	#foreach pair of P in that sublist:
		#calculate dist/grav force between, apply acceleration
while 1:
	while run==1:
		if step%1==0:
			#GRAVITY FORCE CALCULATING
			b1=0
			while b1<len(P):
				for b2 in range(b1+1,len(P)):
					#for every pair of objects
						#find dist between
					dx=P[b2][0][0]-P[b1][0][0]
					dy=P[b2][0][1]-P[b1][0][1]
					d=hypot(dx,dy)
						#if dist > {sum of objects sizes)
					if (d>(P[b1][3]+P[b2][3])) & (d!=0):
							#calculate grav force between
						f=gravf(dx,dy,P[b1][2],P[b2][2])
							#modify velocities by a=F/m
						P[b1][1][0]+=(f[0]/P[b1][2])*1
						P[b1][1][1]+=(f[1]/P[b1][2])*1
						
						P[b2][1][0]-=(f[0]/P[b2][2])*1
						P[b2][1][1]-=(f[1]/P[b2][2])*1
				b1+=1
		b1=0
		#MERGING
		while b1<len(P):
			b2=b1+1
			while b2<len(P):
				dx=P[b2][0][0]-P[b1][0][0]
				dy=P[b2][0][1]-P[b1][0][1]
				d=hypot(dx,dy)
				if (d<=(P[b1][3]+P[b2][3])):
					merge(b1,b2)
				else:
					b2+=1
			b1+=1
		#MOVING AND DRAWING
		w.delete('b')
		for b1 in range(0,len(P)):
			#move objects
			P[b1][0][0]+=P[b1][1][0]
			P[b1][0][1]+=P[b1][1][1]
			#redraw
			w.create_oval(P[b1][0][0]+P[b1][3]+cx,P[b1][0][1]+P[b1][3]+cy,P[b1][0][0]-P[b1][3]+cx,P[b1][0][1]-P[b1][3]+cy,fill=P[b1][4],tags=('b',b1))
		step+=1
		w.update()
		if tb!=-1:
			cx=(ux-2*P[tb][0][0])/2.
			cy=(uy-2*P[tb][0][1])/2.
	w.update()