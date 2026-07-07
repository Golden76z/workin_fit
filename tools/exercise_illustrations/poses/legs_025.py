# Wall Sit Pulse — side view: wall sit deep, then pulsed slightly up. Wall behind back.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2}

# Pose A: deep wall sit — thighs horizontal, back flat on the wall.
a = SideFigure(
    pelvis=(300, 450),
    torso=90, head=90,
    upper_arm=-78, forearm=-74,
    thigh=-8, shin=-90, foot=0,
    highlights=HL,
)
s.add(a)
s.wall(a.j["pelvis"][0] - 22)

# Pose B: pulsed a few inches up — hips higher, knees less bent.
b = SideFigure(
    pelvis=(760, 415),
    torso=90, head=90,
    upper_arm=-78, forearm=-74,
    thigh=-30, shin=-95, foot=0,
    highlights=HL,
)
s.add(b)
s.wall(b.j["pelvis"][0] - 22)

s.chevrons(530, 270)
# small pulse arrows near the hips: up then down
s.arrow((880, 420), (880, 360))
s.arrow((915, 360), (915, 420))

s.save("legs_025")
