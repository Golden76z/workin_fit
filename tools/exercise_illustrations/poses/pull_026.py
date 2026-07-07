# Reverse Grip Hang Hold — side view: isometric hold at the top of a chin-up,
# elbows fully bent, chin at bar height. Single centered pose.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()

# Top of chin-up: elbow bent down-front of the ribs, forearm rising so the hand
# grips the bar in front of (beside) the head, bar just under the chin.
f = SideFigure(
    pelvis=(520, 315),
    torso=85, head=98, head_offset=(0, -7),
    upper_arm=-50, forearm=55,
    thigh=-95, shin=-125, foot=-60,
    snap=False, scale=1.1,
    highlights={"biceps": 3, "forearms": 2, "back": 2},
)
s.bar(f.j["hand"][1], 320, 760)
s.add(f)
if os.environ.get("POSE_DEBUG"):
    print("hand:", f.j["hand"], "head:", f.j["head"])

s.save("pull_026")
