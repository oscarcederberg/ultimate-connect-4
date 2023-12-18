package;

import flixel.FlxState;

class PlayState extends FlxState {
    var board:Board;

    override public function create() {
        super.create();

        this.board = new Board(144, 176);
        add(board);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
    }
}
