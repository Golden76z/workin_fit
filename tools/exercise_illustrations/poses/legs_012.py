# Glute Bridge — side view, supine: lying flat, then hips lifted.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"glutes": 3, "hamstrings": 2}
SUPINE = (0, -1)  # lying on the back: belly faces up

# Pose A: on the back, knees bent, feet flat, arms along the floor.
s.add(SideFigure(
    pelvis=(330, 500),
    torso=181, head=178,
    upper_arm=45, forearm=25,
    thigh=55, shin=-80, foot=-5,
    facing=1, front_hint=SUPINE,
    highlights=HL,
))

# Pose B: hips raised, shoulders and feet on the floor.
s.add(SideFigure(
    pelvis=(800, 470),
    torso=202, head=170,
    upper_arm=25, forearm=15,
    thigh=24, shin=-90, foot=0,
    facing=1, front_hint=SUPINE,
    highlights=HL,
))

s.chevrons(545, 250)
# hips drive upward
s.arrow((760, 420), (775, 330), curve=-15)

s.save("legs_012")
