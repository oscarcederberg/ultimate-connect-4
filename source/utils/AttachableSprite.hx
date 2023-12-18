package utils;

import flixel.FlxObject;
import flixel.FlxSprite;

class AttachableSprite extends FlxSprite implements Attachable {
    var attached:Bool;
    var parent:FlxObject;
    var relativeX:Int;
    var relativeY:Int;

    override function update(elapsed:Float) {
        super.update(elapsed);

        updateAttachment();
    }

    public function attach(parent:FlxObject, x:Int, y:Int) {
        this.parent = parent;
        this.relativeX = x;
        this.relativeY = y;
        this.attached = true;
    }

    public function detach() {
        this.attached = false;
    }

    public function updateAttachment() {
        if (this.attached) {
            setPosition(parent.x + relativeX, parent.y + relativeY);
        }
    }

    public function isAttached():Bool {
        return attached;
    }
}
