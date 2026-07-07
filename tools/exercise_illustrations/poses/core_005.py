# Russian Twists — seated V, leaning back, arms sweep side to side.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"obliques": 3, "abs": 2}

# Pose 1: twisted toward the camera side — hands forward-up.
s.add(SideFigure(
    pelvis=(300, 505),
    torso=112, head=95,
    upper_arm=10, forearm=10,
    thigh=35, shin=-55, foot=10,
    highlights=HL,
))

# Pose 2: twisted away — hands swung down beside the hip.
s.add(SideFigure(
    pelvis=(770, 505),
    torso=112, head=95,
    upper_arm=-50, forearm=-38,
    thigh=35, shin=-55, foot=10,
    highlights=HL,
))

s.chevrons(520, 330)
# arc showing the rotation of the hands
s.arrow((900, 340), (930, 450), curve=45)

s.save("core_005")
