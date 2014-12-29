TclGravity
==========

This is a simple gravity simulator using Newtonian physics. At any one time there are up to 32 objects, and once you have placed the maximum, the oldest objects will be deleted to be replaced by newly placed ones. This avoids the simulation slowing down, and I think 32 objects should be plenty. Every object is effected by the graviational force from every other object.

o You can scale the gravitational constant by pressing the G=G/4 or G=G*4 buttons (this is similar to scaling speed of the simulation, the higher G is the less accurate the calculations become (normally not noticably). Scaling G will also scale the speeds of all the objects, so objects in orbit will stay in orbit (however, making G too high can have unexpected results).
o Start will start or stop the simulation.
o New mass, new size and new col are the settings a newly placed body will have. It is best to have sizes far bigger than reality, they do not affect the gravity felt by the body at all. 
o New col will accept some named colours, and will also accept hex code in the form of "#RRGGBB" (example: #5ac266).
o Left clicking will place an object.
o Right clicking will select an object for the next placed object to be put in orbit around.
o Middle mouse click will replace selected object with new object, stationary.
o Velocity multiplyer is a multiplyer used to skew the orbit of the placed body. If it is 1 the orbit will be circular (if possible, and if there are 2 objects, else it will be slightly skewed).
o Clear will clear all objects from the simulation, ready to start anew.
o Save and Load will save the simulation and load the saved simulation. To have multiple save files you can rename older ones, then rename them to the default name to load them.
o With the arrow keys you can scroll around
o The trace button will place traces for the selected object.
o The mode button switches to a first person mode, however this is not completed and doesn't work yet.
o The black box with a line gives the net direction of the gravitational field at the position of the mouse on the universe, and the number above this shows the magnitude (acceleration). The gravity of the selected object is ignored for this.
o The up, down, left and right arrow keys allow you to scroll around the universe, giving a free view obtion. It is however, easier to follow an object through using the follow button.


It is not always possible for objects to go into orbit around each other. If a moon flies off from a planet you wished it to orbit, it needs to be closer to the planet, or the planet should have been further from the sun.

START UP GUIDE
To set up a simple solar system you can:
1: Set New size to 20
2: Left click in the middle of the screen. This will place your "Sun"
3: Set New mass to 1e9. This will be the mass of your planet.
4: Set new size to 10.
5: Set new col to "green"
6: Right click your sun.
7: Set velocity multiplyer to 1, giving a circular orbit. Less than or greater will give elliptical or hyperbolic orbit.
8: Left click some way away from the sun. This will place your planet in orbit.
9: Set new mass to 1e5. This will be the mass of your planet's moon.
10: Set new size to 5.
11: Set new col to "white"
12: Right click your planet, to select it as the target for your moon to orbit.
13: Left click very close to your planet, and this will place the moon in orbit around it.
14: Press start to run simulation.
15: Press start to stop simulation.
