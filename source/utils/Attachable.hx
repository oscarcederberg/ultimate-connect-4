package utils;

import flixel.FlxObject;

interface Attachable {
    public function attach(parent:FlxObject, x:Int, y:Int):Void;
    public function detach():Void;
    public function updateAttachment():Void;
    public function isAttached():Bool;
}
