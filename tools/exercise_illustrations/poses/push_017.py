# Clapping Push-up — bottom position, then explosive airborne clap.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "shoulders": 2, "triceps": 2}

# Pose A: bottom of push-up, loaded to explode up — hand planted on the floor.
s.add(SideFigure(
    pelvis=(280, 470),
    torso=8, head=16,
    upper_arm=185, forearm=-76,
    thigh=190, shin=192, foot=-110,
    highlights=HL,
))

# Pose B: airborne, both hands meeting in a clap under the chest
# (near arm elbow-back, far arm elbow-forward; hands converge on one point).
s.add(SideFigure(
    pelvis=(760, 420),
    torso=18, head=24,
    upper_arm=-136, forearm=-45,
    far_upper_arm=-36, far_forearm=-127,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

s.chevrons(520, 280)
# explosive up arrow near pose B
s.arrow((980, 470), (980, 330), curve=-20)

s.save("push_017")
