package utils;

import flixel.FlxObject;

interface Attachable {
    public function attach(parent:FlxObject, x:Float, y:Float):Void;
    public function detach():Void;
    public function updateAttachment():Void;
    public function isAttached():Bool;
}
