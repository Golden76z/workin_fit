# Inchworms — forward fold with hands on the floor, then walk hands out to plank.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"shoulders": 3, "abs": 2, "hamstrings": 2}

# Pose A: standing pike fold, hands reaching the floor, legs straight.
s.add(SideFigure(
    pelvis=(260, 250),
    torso=-25, head=-45,                # torso folded down-forward, hips high
    upper_arm=-70, forearm=-70,         # arms reach down, hands on the floor
    thigh=-85, shin=-88, foot=5,
    highlights=HL,
))

# Pose B: hands walked out into a plank.
s.add(SideFigure(
    pelvis=(790, 430),
    torso=18, head=24,
    upper_arm=-85, forearm=-85,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

s.chevrons(500, 290)
# hands walk forward along the ground
s.arrow((380, 500), (560, 500), curve=-25)

s.pulse_icon()
s.save("cardio_008")
