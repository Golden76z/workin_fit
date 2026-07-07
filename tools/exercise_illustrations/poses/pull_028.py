# Scapular Push-up — side view: high plank, shoulder blades protracted (pushed
# tall) then retracted (chest sinks between straight arms). Elbows never bend.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"back": 3, "shoulders": 2, "chest": 2}

# Pose A: protracted — shoulders pushed away from the floor, upper back tall.
s.add(SideFigure(
    pelvis=(300, 435),
    torso=24, head=8,
    upper_arm=-85, forearm=-85,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

# Pose B: retracted — chest sinks between the arms, shoulders pinch back.
# Arms stay straight; only the shoulder girdle drops.
s.add(SideFigure(
    pelvis=(790, 445),
    torso=9, head=30,
    upper_arm=-85, forearm=-85,
    thigh=203, shin=204, foot=-105,
    highlights=HL,
))

s.chevrons(540, 290)
# small up/down cue at the shoulders of pose B
s.arrow((990, 335), (990, 410))
s.arrow((1025, 410), (1025, 335))

s.save("pull_028")
