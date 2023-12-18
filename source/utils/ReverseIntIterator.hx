package utils;

class ReverseIntIterator {
    var end:Int;
    var current:Int;

    public inline function new(startExclusive:Int, endInclusive:Int) {
        this.current = startExclusive - 1;
        this.end = endInclusive;
    }

    public inline function hasNext() {
        return current >= end;
    }

    public inline function next() {
        return current--;
    }
}
