# Dock Labels

## Observation

Consider the alignment of a dock icon with respect to the label that appears when hovering over it. If we draw a box (pale-white) which is bounded by the edges of the label, and we measure the distance from the app's edges to the edges of the box, we see the app icon biased to the right side. We can prove this by adding a spacer (dark blue) which is flush to the app on its left edge. When that same spacer is placed on the white box's right edge, we see it interfering with the right edge of the app icon by a few pixels. 

<img width="555" height="751" alt="Image" src="https://github.com/user-attachments/assets/386949fa-7a17-48a3-9a56-4bdd4f668f72" />

Interestingly, this off-center alignment is _not_ present in the indicator dot under the app's icon, which is in fact perfectly centered with the icon. This causes me to suspect that the dock label is somehow appearing off-center from the icon-indicator stack by a few pixels.

<img width="555" height="682" alt="Image" src="https://github.com/user-attachments/assets/6302f9e7-a322-4937-a89b-7c2e54d20685" />
