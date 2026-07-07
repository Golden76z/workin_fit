# Single Leg Glute Bridge — supine: one foot planted, other leg extended;
# then hips driven up with the free leg in line with the torso.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"glutes": 3, "hamstrings": 2}
SUPINE = (0, -1)

# Pose A: on the back, one knee bent foot flat, other leg extended upward.
s.add(SideFigure(
    pelvis=(320, 500),
    torso=181, head=178,
    upper_arm=45, forearm=25,
    thigh=55, shin=55, foot=55,           # extended (near) leg, in line with the planted thigh
    far_thigh=55, far_shin=-80, far_foot=-5,   # planted leg
    facing=1, front_hint=SUPINE,
    highlights=HL,
))

# Pose B: hips lifted, extended leg in line with the raised torso.
s.add(SideFigure(
    pelvis=(790, 470),
    torso=202, head=170,
    upper_arm=25, forearm=15,
    thigh=32, shin=32, foot=32,           # extended (near) leg
    far_thigh=24, far_shin=-90, far_foot=0,    # planted leg, shin vertical
    facing=1, front_hint=SUPINE,
    highlights=HL,
))

s.chevrons(545, 250)
# hips drive upward
s.arrow((740, 440), (755, 350), curve=-15)

s.save("legs_013")
