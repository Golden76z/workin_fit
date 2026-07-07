# Bodyweight Hip Thrust — supine: upper back on the floor, feet flat,
# hips driven to full extension (knee-hip-shoulder in a straight line).
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"glutes": 3, "hamstrings": 2}
SUPINE = (0, -1)

# Pose A: on the back, knees bent, feet flat, hips resting on the floor.
s.add(SideFigure(
    pelvis=(310, 512),
    torso=179, head=176,
    upper_arm=42, forearm=22,
    thigh=58, shin=-78, foot=-5,
    facing=1, front_hint=SUPINE,
    highlights=HL,
))

# Pose B: full hip extension — knee-hip-shoulder in one straight line,
# feet flat, shoulders on the floor.
s.add(SideFigure(
    pelvis=(770, 486),
    torso=206, head=170,
    upper_arm=22, forearm=12,
    thigh=26, shin=-92, foot=-5,
    facing=1, front_hint=SUPINE,
    highlights=HL,
))

s.chevrons(540, 250)
# hips punch straight up to lockout
s.arrow((730, 455), (740, 365), curve=-12)

s.save("legs_035")
