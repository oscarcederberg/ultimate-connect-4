package utils;

import flixel.FlxObject;
import utils.AttachableObject;

class Hitbox extends AttachableObject {
    public function new(parent:FlxObject, relativeX:Float, relativeY:Float, width:Int, height:Int) {
        super(parent.x + relativeX, parent.y + relativeY, width, height);

        attach(parent, relativeX, relativeY);
    }
}
