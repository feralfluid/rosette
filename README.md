# rosette

a simple flip book animation app

# bindings

**space:** paws/play

**left:** previous frame, creates a new frame and pushes the rest back if you're already on frame 1

**right:** next frame, creates a new frame if you're already on the last frame

**up:** increase fps

**down:** decrease fps

**backspace:** deletes the current frame, clears if its the only frame

**enter/return:** clears the current frame

**i:** inserts new frame

**d:** duplicates the current frame

**scroll wheel:** adjusts brush size

**e:** toggles eraser tool

**o:** toggles onion skinning

**s:** saves all frames as .png's into the love2d save directory (in the "rosette" folder) as specified by: https://love2d.org/wiki/love.filesystem

**escape:** quits the app