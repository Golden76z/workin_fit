# Sliding Hamstring Curl — supine: legs extended with heels on the floor,
# then heels slid toward the glutes into a bridge.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"hamstrings": 3, "glutes": 2}
SUPINE = (0, -1)

# Pose A: lying flat on the back, legs almost straight, heels on the floor.
s.add(SideFigure(
    pelvis=(280, 520),
    torso=183, head=180,
    upper_arm=40, forearm=20,
    thigh=-10, shin=-4, foot=80,
    facing=1, front_hint=SUPINE,
    highlights=HL,
))

# Pose B: heels pulled under the knees, hips lifted into a bridge
# (heels on the floor, toes up — the sliding surface).
s.add(SideFigure(
    pelvis=(770, 486),
    torso=205, head=172,
    upper_arm=30, forearm=15,
    thigh=21, shin=-90, foot=60,
    facing=1, front_hint=SUPINE,
    highlights=HL,
))

s.chevrons(540, 260)
# heels slide back along the floor toward the glutes
s.arrow((985, 505), (890, 505), curve=-10)

s.save("legs_030")
