# Typewriter Push-up — side view: stay at the bottom of a push-up and glide
# from one arm to the other; the loaded arm is fully bent, the other extended.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "triceps": 2, "abs": 2}

# Pose A: bottom shifted over the near arm (deep bend, elbow back),
# far arm extended straight with the hand still planted.
s.add(SideFigure(
    pelvis=(290, 470),
    torso=6, head=12,
    upper_arm=170, forearm=-80,
    far_upper_arm=-28, far_forearm=-24,
    thigh=186, shin=188, foot=-100,
    highlights=HL,
))

# Pose B: weight slid to the other arm — near arm now extended straight,
# far arm fully bent behind the shoulder.
s.add(SideFigure(
    pelvis=(760, 470),
    torso=6, head=12,
    upper_arm=-28, forearm=-24,
    far_upper_arm=170, far_forearm=-80,
    thigh=186, shin=188, foot=-100,
    highlights=HL,
))

s.chevrons(545, 300)
# side-to-side glide cue while staying low
s.arrow((880, 370), (980, 370))
s.arrow((980, 400), (880, 400))

s.save("push_029")
