tiles:

1. basic flat tile, walk on and push boulder onto normally
2. angled tile, boulder slide down unless colliding with player, player isn't affected. only care about up northeast - down southwest direction
3. tree tile, can not be walked on nor push the boulder onto
4. river tile going southeast, push boulder and player southeast. min 2 frame animation
5. river tile going northwest, push boulder and player southwest. min 2 frame animation
6. mud tile, player and boulder sink if in a continuous puddle of mud for too long, player pushes boulder more slowly if either in mud. the "sinking" should be visible, but we can probably do a trick where the sprite itself is moved downward and cut off but the object hitbox is still the same
