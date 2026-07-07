# Clamshells — side-lying, knees bent and stacked; the top knee opens up
# while the feet stay together.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"glutes": 3}
HINT = (0, -1)  # belly drawn facing up-screen

# Pose A: lying on the side, hips and knees bent, knees stacked (closed clam).
s.add(SideFigure(
    pelvis=(330, 500),
    torso=175, head=178,
    upper_arm=185, forearm=140,      # bottom arm folded under the head
    thigh=35, shin=-55, foot=-55,
    facing=1, front_hint=HINT,
    highlights=HL,
))

# Pose B: top knee lifted open, feet kept together.
s.add(SideFigure(
    pelvis=(800, 500),
    torso=175, head=178,
    upper_arm=185, forearm=140,
    thigh=62, shin=-55, foot=-55,               # top leg opened
    far_thigh=35, far_shin=-55, far_foot=-55,   # bottom leg stays down
    facing=1, front_hint=HINT,
    highlights=HL,
))

s.chevrons(545, 250)
# knee rotates open around the feet
s.arrow((900, 460), (855, 385), curve=-20)

s.save("legs_016")
