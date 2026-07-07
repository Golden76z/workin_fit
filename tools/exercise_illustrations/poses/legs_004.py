# Bulgarian Split Squat — side view: rear foot on a chair/box, top position
# then deep bottom position. Box is anchored under the rear foot.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2}

# Pose A: top — front leg nearly straight, rear foot resting on box behind.
fa = SideFigure(
    pelvis=(300, 380),
    torso=85, head=88,
    upper_arm=-78, forearm=-74,
    thigh=-80, shin=-92, foot=0,
    far_thigh=-152, far_shin=-168, far_foot=205,
    highlights=HL,
)
s.add(fa)
tx, ty = fa.j["far_toe"]
s.box(tx - 105, ty + 7, 130, 548 - (ty + 7))

# Pose B: bottom — front knee bent ~90°, rear knee dropped, foot stays on box.
fb = SideFigure(
    pelvis=(790, 450),
    torso=80, head=85,
    upper_arm=-78, forearm=-74,
    thigh=-35, shin=-100, foot=0,
    far_thigh=-105, far_shin=140, far_foot=185,
    highlights=HL,
)
s.add(fb)
tx2, ty2 = fb.j["far_toe"]
s.box(tx2 - 105, ty2 + 7, 130, 548 - (ty2 + 7))

s.chevrons(520, 280)
s.arrow((640, 300), (615, 400), curve=25)

s.save("legs_004")
