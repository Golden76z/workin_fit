# Towel Row — towel wrapped around a door-edge anchor, lean back and row.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()

HL = {"back": 3, "biceps": 2, "forearms": 2}

# Pose A: leaning back, arms extended, holding the towel ends.
s.wall(403)
fa = SideFigure(
    pelvis=(245, 380),
    torso=117, head=105,
    upper_arm=-18, forearm=-12,
    thigh=-63, shin=-63, foot=0,
    highlights=HL,
)
s.add(fa)
# towel: doubled line from the door anchor to the hands
s.line((403, 332), (fa.j["hand"][0] + 4, fa.j["hand"][1] - 4))
s.line((403, 340), (fa.j["hand"][0] + 4, fa.j["hand"][1] + 5))

# Pose B: pulled up to the towel, elbows bent back.
s.wall(827)
fb = SideFigure(
    pelvis=(740, 380),
    torso=100, head=95,
    upper_arm=-128, forearm=2,
    thigh=-77, shin=-77, foot=0,
    highlights=HL,
)
s.add(fb)
s.line((827, 326), (fb.j["hand"][0] + 4, fb.j["hand"][1] - 4))
s.line((827, 334), (fb.j["hand"][0] + 4, fb.j["hand"][1] + 5))
print("A hand:", fa.j["hand"], " B hand:", fb.j["hand"])

s.chevrons(520, 200)
# pull toward the anchor
s.arrow((590, 420), (670, 420))

s.save("pull_014")
