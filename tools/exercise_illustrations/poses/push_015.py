# Wall Sit — isometric hold: back flat against a wall, thighs parallel to
# the floor, shins vertical. Single centered pose with the wall behind.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2}

f = SideFigure(
    pelvis=(430, 400),
    torso=90, head=88,
    upper_arm=-78, forearm=-74,
    thigh=-4, shin=-90, foot=0,
    scale=1.25,
    highlights=HL,
)
s.add(f)

# wall right behind the back
s.wall(398)

# small arrow: hips held low, sliding down against the wall
s.arrow((640, 290), (640, 370))

s.save("push_015")
