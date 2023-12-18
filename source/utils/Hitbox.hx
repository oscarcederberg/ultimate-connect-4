package utils;

import utils.AttachableObject;
import flixel.FlxObject;

class Hitbox extends AttachableObject {
    public function new(parent:FlxObject, relativeX:Int, relativeY:Int,
            width:Int, height:Int) {
        super(parent.x + relativeX, parent.y + relativeY, width, height);

        attach(parent, relativeX, relativeY);
    }
}
