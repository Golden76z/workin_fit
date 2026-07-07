# Pseudo Planche Push-up — push-up with hands pulled back toward the waist,
# shoulders leaning forward past the wrists. Top pose then bent-elbow bottom.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "shoulders": 2, "triceps": 2, "abs": 2}

# Pose A: top — arms straight but angled back so the hands sit near the
# waist, shoulders forward of the wrists, toes pointed.
s.add(SideFigure(
    pelvis=(300, 440),
    torso=12, head=20,
    upper_arm=-118, forearm=-112,
    thigh=206, shin=206, foot=-108,
    highlights=HL,
))

# Pose B: bottom — elbows bent back, chest low, hands still by the waist.
s.add(SideFigure(
    pelvis=(790, 480),
    torso=6, head=14,
    upper_arm=178, forearm=-60,
    thigh=194, shin=196, foot=-165,
    highlights=HL,
))

s.chevrons(530, 280)
# down-then-up motion cue near pose B
s.arrow((1000, 390), (1000, 480))
s.arrow((1040, 480), (1040, 390))

s.save("push_016")
