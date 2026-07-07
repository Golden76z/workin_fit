# Scapular Wall Slides — back against wall, arms slide from bent W to overhead.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()

HL = {"back": 3, "shoulders": 2}

# Pose A: standing back to wall, elbows down near the wall, forearms up (W).
s.wall(285)
fa = SideFigure(
    pelvis=(335, 370),
    torso=92, head=88,
    upper_arm=-118, forearm=97,
    thigh=-90, shin=-90, foot=0,
    highlights=HL,
)
s.add(fa)

# Pose B: arms extended straight overhead along the wall.
s.wall(755)
fb = SideFigure(
    pelvis=(790, 370),
    torso=92, head=88,
    upper_arm=102, forearm=100,
    thigh=-90, shin=-90, foot=0,
    highlights=HL,
)
s.add(fb)

s.chevrons(540, 260)
# hands slide up the wall
s.arrow((880, 260), (880, 170))

s.save("pull_010")
