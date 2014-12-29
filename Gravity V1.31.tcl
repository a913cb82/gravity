#===============================================
#DEFINE GENERAL CONSTANTS
#===============================================
set ux 800				;#screen x
set uy 800				;#screen y
set filename GravSave	;#file to save to/load from
set obj 0				;#most recently placed object
set step 0				;#number of cycles of main loop
set G  1				;#gravitational constant
set Gs 0				;#number of times you have multiplyed/divided G
set rdraw 1				;#redraw time
set numtra 1023			;#number of tracing objects
set tracet 15			;#tracer place time
set tracen -1			;#most recently placed tracer
set traceon -1			;#1=tracing enabled, -1=disabled
set simon -1			;#simulation running, -1=stop, 1=start
set maxobj 31			;#max objects
set omag 1				;#multiplyer for orbital speed
set flw -1				;#follow object, keep it at centre of screen. -1=off, else follow object specified by number
set mode 1				;#1=above view, -1=1st person from selected obj
set ang 0				;#my angle in 1st person mode
set cx 0				;#camera x
set cy 0				;#camera y
set gravmag 0			;#gravitation acceleration at mouse position
set mx 400
set my 400
#New object settings
set nm  1e2			;#new mass
#Object to go in orbit around
set tobj -1
#Object settings
set x ""
set y ""
set m ""
set s ""
set vx ""
set vy ""

#FRAMES, UNIVERSE AND BUTTONS
frame .t
frame .b
grid .t -in . -row 1 -column 1
grid .b -in . -row 2 -column 1
frame .tl
frame .tr
grid .tl -in .t -row 1 -column 1
grid .tr -in .t -row 1 -column 2
#UNIVERSE CANVAS
canvas .universe -width $ux -height $uy -bg black
grid .universe -in .b -row 1 -column 1

for {set n 0} {$n<=$maxobj} {incr n} {
	.universe create oval 0 0 0 0 -tag obj($n) -fill black -outline black
		lappend x 0
		lappend y 0
		lappend m 1e-100
		lappend s 0
		lappend vx 0
		lappend vy 0
}

for {set n 0} {$n<$numtra} {incr n} {
	.universe create oval 0 0 0 0 -tag tra($n) -fill white -outline white
}
#===============================================
#GUI
#===============================================

#GDIV, GMUL AND START
label .glab -textvariable Gs
button .gdiv -text "G=G/4" -command "gdiv"
button .gmul -text "G=G*4" -command "gmul"
button .go -text "Start" -command "start"
grid .gdiv -in .tl -row 1 -column 1 -sticky ew
grid .gmul -in .tl -row 2 -column 1 -sticky ew
grid .go -in .tl -row 3 -column 1 -sticky ew
grid .glab -in .tl -row 1 -column 2

#NEW OBJECT SETTINGS
label .nml -text "New mass:"
grid .nml -in .tl -row 1 -column 3 -sticky e
entry .nme -textvariable nm -width 15
grid .nme -in .tl -row 1 -column 4 -sticky w

#VELOCITY MULTIPLYER
label .ovml -text "Velocity multiplyer:"
entry .ovme -textvariable omag -width 5
grid .ovml -in .tl -row 1 -column 5
grid .ovme -in .tl -row 1 -column 6

#SELECTED BODY
label .selbl -text "Selected body:"
label .selbv -textvariable tobj
grid .selbl -in .tl -row 2 -column 5 -sticky e
grid .selbv -in .tl -row 2 -column 6 -sticky w

#CLEAR
button .clr -text "Clear" -command "clr"
grid .clr -in .tl -row 3 -column 5 -sticky ew

#FOLLOW BUTTON
button .flw -text "Follow" -command "follow"
grid .flw -in .tl -row 3 -column 6 -sticky ew

#LOAD AND SAVE
button .lod -text "Load" -command "lod"
button .save -text "Save" -command "save"
grid .lod -in .tl -row 1 -column 7 -sticky ew
grid .save -in .tl -row 2 -column 7 -sticky ew
entry .flen -textvariable filename -width 10
grid .flen -in .tl -row 1 -column 8 -sticky w

#TRACING ON/OFF
button .tra -text "Trace" -command "traceonoff"
grid .tra -in .tl -row 3 -column 7 -sticky ew

#SWAP MODE
button .mode -text "Mode" -command "mode"
grid .mode -in .tl -row 2 -column 8 -sticky ew

#SIGNATURE
label .sig -text "Gravity 1.31 by a913cb82"
grid .sig -in .b -row 2 -column 1

#GRAVITY VIEWER
label .gravmag -textvariable gravmag
canvas .gravdir -width 50 -height 50 -bg black
grid .gravmag -in .tr -row 1 -column 1
grid .gravdir -in .tr -row 2 -column 1
.gravdir create line 25 25 0 50 -tag gd -fill white

proc lod {} {
	global filename
	upvar obj obj
	upvar cx cx
	upvar cy cy
	upvar x x
	upvar y y
	upvar m m
	upvar s s
	upvar vx vx
	upvar vy vy
	set file [open "$filename.gra" r]
	set info [read $file]
	close $file
	puts $info
	set obj [lindex $info 0]
	set cx [lindex $info 1]
	set cy [lindex $info 2]
	set x [lrange $info [expr {[lsearch $info #XS#]+1}] [expr {[lsearch $info #XE#]-1}]]
	set y [lrange $info [expr {[lsearch $info #YS#]+1}] [expr {[lsearch $info #YE#]-1}]]
	set m [lrange $info [expr {[lsearch $info #MS#]+1}] [expr {[lsearch $info #ME#]-1}]]
	set s [lrange $info [expr {[lsearch $info #SS#]+1}] [expr {[lsearch $info #SE#]-1}]]
	set vx [lrange $info [expr {[lsearch $info #VXS#]+1}] [expr {[lsearch $info #VXE#]-1}]]
	set vy [lrange $info [expr {[lsearch $info #VYS#]+1}] [expr {[lsearch $info #VYE#]-1}]]
	global maxobj
	for {set n 0} {$n<$maxobj} {incr n} {
		set xx [lindex $x $n]
		set xy [lindex $y $n]
		set xs [lindex $s $n]
		.universe coords obj($n)	[expr {$xx-$xs/2}] [expr {$xy-$xs/2}] \
									[expr {$xx+$xs/2}] [expr {$xy+$xs/2}]
		.universe itemconfigure obj($n) -fill yellow
	}
}
proc save {} {
	global filename
	global obj
	global cx
	global cy
	global x
	global y
	global m
	global s
	global vx
	global vy
	set save "$obj $cx $cy \n #XS# $x #XE# \n #YS# $y #YE# \n #MS# $m #ME# \n #SS# $s #SE# \n #VXS# $vx #VXE# \n #VYS# $vy #VYE#"
	set savefile [open "$filename.gra" w]
	puts $savefile $save
	close $savefile
}
proc clr {} {
	upvar x x;set x ""
	upvar y y;set y ""
	upvar m m;set m ""
	upvar s s;set s ""
	upvar vx vx;set vx ""
	upvar vy vy;set vy ""
	global maxobj
	for {set n 0} {$n<=$maxobj} {incr n} {
			lappend x 0
			lappend y 0
			lappend m 1e-100
			lappend s 0
			lappend vx 0
			lappend vy 0
			.universe itemconfigure obj($n) -fill black
	}
}
proc gdiv {} {upvar G G;set G [expr {$G/4}];upvar Gs Gs;incr Gs -1
	upvar vx x;set len [llength $x]
	for {set n 0} {$n<$len} {incr n} {lset x $n [expr {[lindex $x $n]/2}]}
	upvar vy y;set len [llength $y]
	for {set n 0} {$n<$len} {incr n} {lset y $n [expr {[lindex $y $n]/2}]}
}
proc gmul {} {upvar G G;set G [expr {$G*4}];upvar Gs Gs;incr Gs
	upvar vx x;set len [llength $x]
	for {set n 0} {$n<$len} {incr n} {lset x $n [expr {[lindex $x $n]*2}]}
	upvar vy y;set len [llength $y]
	for {set n 0} {$n<$len} {incr n} {lset y $n [expr {[lindex $y $n]*2}]}
}
proc start {} {upvar simon simon;set simon [expr {$simon*-1}]}

proc {follow} {} {upvar flw flw;global tobj;set flw $tobj}

proc traceonoff {} {upvar traceon traceon;set traceon [expr {$traceon*-1}];global numtra
for {set n 0} {$n<$numtra} {incr n} {
	.universe coords tra($n)	0 0 0 0
}}

proc mode {} {upvar mode mode;set mode [expr {$mode*-1}];global tobj;.universe coords obj($tobj) 0 0 0 0}

#===============================================
#KEY PRESSES
#===============================================
bind .universe <Motion> "mmove %x %y"
bind .universe <ButtonPress-1> "lmouseclick %x %y"
bind .universe <ButtonPress-2> "mmouseclick %x %y"
bind .universe <ButtonPress-3> "rmouseclick %x %y"

bind . <KeyPress-a>	"a"
bind . <KeyPress-d>	"d"
proc a {} {upvar ang ang;set ang [expr {$ang+0.1}]}
proc d {} {upvar ang ang;set ang [expr {$ang-0.1}]}


bind . <KeyPress-Up>	"up"
bind . <KeyPress-Down>	"down"
bind . <KeyPress-Right>	"right"
bind . <KeyPress-Left>	"left"
proc up {} {upvar cy cy;incr cy 5}
proc down {} {upvar cy cy;incr cy -5}
proc right {} {upvar cx cx;incr cx -5}
proc left {} {upvar cx cx;incr cx 5}
proc mmove {x y} {
	upvar mx mx;upvar my my
	set mx $x;set my $y
}
proc lmouseclick {nx ny} {
	global nm
	global cx
	global cy
	set nx [expr {$nx-$cx}]
	set ny [expr {$ny-$cy}]
	upvar x x
	upvar y y
	upvar m m
	upvar s s
	upvar vx vx
	upvar vy vy
	upvar obj obj
	global maxobj
	set ncol yellow
	puts $maxobj
	.universe itemconfigure obj($obj) -fill $ncol
		lset x $obj $nx
		lset y $obj $ny
		lset m $obj $nm
		lset s $obj [expr {int($nm**0.5)+1}]
	
	global tobj
	if {$tobj!=-1} {
		global G
		set tx [lindex $x $tobj]
		set ty [lindex $y $tobj]
		set tm [lindex $m $tobj]
		set tvx [lindex $vx $tobj]
		set tvy [lindex $vy $tobj]
		
		set rx [expr {$tx-$nx}]
		set ry [expr {$ty-$ny}]
		set r [expr {sqrt($rx*$rx+$ry*$ry)}]
		global omag
		set vc [expr {sqrt(($G*$tm)/$r)*$omag}]
			set urx [expr {-$ry/$r}]
			set ury [expr {$rx/$r}]
		set nvx [expr {$urx*$vc+$tvx}]
		set nvy [expr {$ury*$vc+$tvy}]
	} else {set nvx 0;set nvy 0}
	puts $nvx
	puts $nvy
	lset vx $obj $nvx
	lset vy $obj $nvy
	set obj [expr {($obj+1)&$maxobj}]
}
proc mmouseclick {nx ny} {
	global nm
	global cx
	global cy
	set nx [expr {$nx-$cx}]
	set ny [expr {$ny-$cy}]
	upvar x x
	upvar y y
	upvar m m
	upvar s s
	upvar vx vx
	upvar vy vy
	global tobj
	set ncol yellow
	if {$tobj!=-1} {
		.universe itemconfigure obj($tobj) -fill $ncol
			lset x $tobj $nx
			lset y $tobj $ny
			lset m $tobj $nm
			lset s $tobj [expr {int($nm**0.5)+1}]
		
			lset vx $tobj 0
			lset vy $tobj 0
		
		upvar obj obj
		set obj $tobj
		incr obj
	}
}
proc rmouseclick {mx my} {
	set item [.universe find overlapping $mx $my $mx $my]
	set coords [.universe coords $item]
	
	set tt 0
	set tl 0
	
	set l [lindex $coords 0]
	set t [lindex $coords 1]
	set r [lindex $coords 2]
	set b [lindex $coords 3]
	upvar tobj tobj
	global maxobj
	for {set n 0} {$n<=$maxobj} {incr n} {
		set tobj -1
		set tl [lindex [.universe coords obj($n)] 0]
		set tt [lindex [.universe coords obj($n)] 1]
		if {$tl==$l && $tt==$t} {set tobj $n;break}
	}
	puts $tobj
}

#===============================================
#REDRAWING
#===============================================
proc redraw {} {
	global mode
	global x;global y;global s
	global cx;global cy
	global maxobj
	if {$mode==1} {
		#REDRAW 3RD PERSON
		for {set n 0} {$n<=$maxobj} {incr n} {
			set xx [lindex $x $n]
			set xy [lindex $y $n]
			set xs [lindex $s $n]
			.universe coords obj($n)	[expr {$xx-$xs/2+$cx}] [expr {$xy-$xs/2+$cy}] \
										[expr {$xx+$xs/2+$cx}] [expr {$xy+$xs/2+$cy}]
		} 
	} else {
		global tobj
		global ang
		global ux;global uy
		#REDRAW 1ST PERSON
		set mx [lindex $x $tobj]
		set my [lindex $y $tobj]
		for {set n 0} {$n<=$maxobj} {incr n} {
			if {$n==$tobj} {incr n;if {$n>$maxobj} {break}}					;#skip seleted object
			set tx [lindex $x $n]
			set ty [lindex $y $n]
			set ts [lindex $s $n]
			
			#dx=tx-mx
			#dy=ty-my
			set dx [expr {$tx-$mx}]
			set dy [expr {$ty-$my}]
			#r=sqrt(dx^2+dy^2)
			set r [expr {sqrt($dx*$dx+$dy*$dy)}]
			#tdx=dx/r
			#tdy=dy/r
			set tdx [expr {$dx/$r}]
			set tdy [expr {$dy/$r}]
			#vdx=sin(ang)
			#vdy=cos(ang)
			set vdx [expr {sin($ang)}]
			set vdy [expr {cos($ang)}]
			#a=acos(tdx*vdx+tdy*vdy)
			set a [expr {acos($tdx*$vdx+$tdy*$vdy)}]
			if {$tdx>$vdx} {set a [expr {6.283185307-$a}]}
			if {$tdx<$vdx} {puts yay}
			#rx=r*sin(a)
			#ry=r*cos(a)
			set rx [expr {$r*sin($a)}]
			set ry [expr {$r*cos($a)}]
			#d=ry*tan(0.5)
			set d [expr {$ry*tan(0.5)}]
			#pos=ux*(d+rx)/(2*d)
			#size=ts/r*ux/4
			set pos [expr {$ux*($d+$rx)/(2*$d)}]
			set size [expr {$ts/$r*$ux/4}]
			if {$size>5} {puts "n=$n \n dx=$dx dy=$dy \n r=$r \n tdx=$tdx tdy=$tdy \n vdx=$vdx vdy=$vdy \n a=$a \n rx=$rx ry=$ry \n d=$d \n pos=$pos \n"}
			.universe coords obj($n)	[expr {$pos-$size}] [expr {$uy/2-$size}] \
										[expr {$pos+$size}] [expr {$uy/2+$size}]
		}
	}
}
#===============================================
#GRAVITATIONAL ACCELERATION
#===============================================
proc ogravacc {x1 y1 x2 y2 m2} {						;#gravacc between two individual objects
	global G
	set dx [expr {$x2-$x1}]
	set dy [expr {$y2-$y1}]
	set d  [expr {sqrt($dx*$dx+$dy*$dy)}]				;#pythag, total dist
	if {$d==0} {set at "0 0"} elseif {$d!=0} {			;#if object is us/on us, return 0 and leave loop
		set a [expr {($G*$m2)/($d*$d)}]					;#equation of gravity, ag=(Gm1m2)/d^2/m1=(Gm2)/d^2
		set ux [expr {$dx/$d}]							;#unit x and y
		set uy [expr {$dy/$d}]
		set ax [expr {$ux*$a}]							;#get x and y acceleratons
		set ay [expr {$uy*$a}]
		set at "$ax $ay"								;#store ax and ay in a list, where 0=ax and 1=ay
	}
	return $at											;#return ax and ay stored in a list
}

#===============================================
#MAIN LOOP
#===============================================
while {1} {
	while {$simon==1} {
		#ACCELERATE OBJECTS
		for {set o 0} {$o<=$maxobj} {incr o} {
			for {set n 0} {$n<=$maxobj} {incr n} {			;#total gravacc for a single object, o=object number
				set xx [lindex $x $o]
				set xy [lindex $y $o]
				set xvx [lindex $vx $o]
				set xvy [lindex $vy $o]
				if {$n!=$o} {								;#only do this is object is not itself
					set yx [lindex $x $n]
					set yy [lindex $y $n]
					set ym [lindex $m $n]
					set a [ogravacc $xx $xy $yx $yy $ym]
					set ax [lindex $a 0]					;#get individual objects x and y acc
					set ay [lindex $a 1]
					lset vx $o [expr {$xvx+$ax}]
					lset vy $o [expr {$xvy+$ay}]
				}
			}
		}
		#REPOSITION
		for {set n 0} {$n<=$maxobj} {incr n} {
			set xx [lindex $x $n]
			set xy [lindex $y $n]
			set xvx [lindex $vx $n]
			set xvy [lindex $vy $n]
			lset x $n  [expr {$xx+$xvx}]
			lset y $n  [expr {$xy+$xvy}]
		}
		#MOUSE'S GRAVITY
		set mnx [expr {$mx-$cx}];set mny [expr {$my-$cy}]
		set gax 0;set gay 0	;#total grav acc x & y
		for {set n 0} {$n<=$maxobj} {incr n} {
			if {$n!=$tobj} {						;#don't include gravity of selected object
				set yx [lindex $x $n]
				set yy [lindex $y $n]
				set ym [lindex $m $n]
				set a [ogravacc $mnx $mny $yx $yy $ym]	;#a={ax ay}
				set ax [lindex $a 0]					;#get individual objects x and y acc
				set ay [lindex $a 1]
				set gax [expr {$gax+$ax}]
				set gay [expr {$gay+$ay}]
			}
		}
		set a [expr {sqrt($gax*$gax+$gay*$gay)}]	;#pythag gax and gay to get a magnitude
		set gravmag [expr {int($a*100000)}]
		#Get unit x and unit y
		#Multiply both by 25
		#Add 25 to each
		set unx [expr {$gax/$a*25+25}]
		set uny [expr {$gay/$a*25+25}]
		.gravdir coords gd 25 25 $unx $uny
		#REDRAW
		redraw
		
		if {$mode==1} {
			#TRACING
			if {$step%$tracet==0 && $traceon==1 && $tobj!=-1} {
				set tracen [expr {($tracen+1)&$numtra}]
				set xx [lindex $x $tobj]
				set xy [lindex $y $tobj]
				set xs [lindex $s $tobj]
				.universe coords tra($tracen)	[expr {$xx-1+$cx}] [expr {$xy-1+$cy}] \
												[expr {$xx+1+$cx}] [expr {$xy+1+$cy}]
			}
			#FOLLOW
			if {$flw!=-1} {
				set xx [lindex $x $flw]
				set xy [lindex $y $flw]
				set cx [expr {int(($ux-2*$xx)/2)}]
				set cy [expr {int(($uy-2*$xy)/2)}]
			}
		}
		after 1 {set sleep {}}
		tkwait variable sleep
		incr step
	}
	redraw
	#FOLLOW
	if {$flw!=-1 && $mode==1} {
		set xx [lindex $x $flw]
		set xy [lindex $y $flw]
		set cx [expr {int(($ux-2*$xx)/2)}]
		set cy [expr {int(($uy-2*$xy)/2)}]
	}
	
	#MOUSE'S GRAVITY
	set mnx [expr {$mx-$cx}];set mny [expr {$my-$cy}]
	set gax 0;set gay 0	;#total grav acc x & y
	for {set n 0} {$n<=$maxobj} {incr n} {
		if {$n!=$tobj} {							;#don't include gravity of selected object
			set yx [lindex $x $n]
			set yy [lindex $y $n]
			set ym [lindex $m $n]
			set a [ogravacc $mnx $mny $yx $yy $ym]	;#a={ax ay}
			set ax [lindex $a 0]					;#get individual objects x and y acc
			set ay [lindex $a 1]
			set gax [expr {$gax+$ax}]
			set gay [expr {$gay+$ay}]
		}
	}
	set a [expr {sqrt($gax*$gax+$gay*$gay)}]		;#pythag gax and gay to get a magnitude
	set gravmag [expr {int($a*100000)}]
	#Get unit x and unit y
	#Multiply both by 25
	#Add 25 to each
	set unx [expr {$gax/$a*25+25}]
	set uny [expr {$gay/$a*25+25}]
	.gravdir coords gd 25 25 $unx $uny
	
	
	after 1 {set sleep {}}
	tkwait variable sleep
}