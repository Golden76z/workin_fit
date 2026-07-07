# Reverse Plank — face-up hold: hands under shoulders, body straight, heels on floor.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()

SUPINE = (0, -1)
f = SideFigure(
    pelvis=(530, 430),
    torso=157, head=172,
    upper_arm=-100, forearm=-100,
    thigh=-33, shin=-33, foot=50,
    scale=1.25,
    front_hint=SUPINE,
    highlights={"back": 3, "glutes": 2, "hamstrings": 2, "shoulders": 2},
)
s.add(f)
# hips-up effort hint
s.arrow((600, 395), (600, 335))

s.save("pull_009")
