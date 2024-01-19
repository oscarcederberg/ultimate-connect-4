import GameModel.BoardModel;
import GameModel.GameTurn;
import flixel.FlxSprite;

class OmegaBoardPiece extends FlxSprite {
    public static inline final SIZE = 48;

    override public function new(x:Float, y:Float, player:GameTurn) {
        super(x, y);

        loadGraphic("assets/images/piece_omega.png", true, SIZE);
        animation.add("blue", [0]);
        animation.add("red", [1]);

        switch player {
        case Blue:
            animation.play("blue");
        case Red:
            animation.play("red");
        }
    }
}

class OmegaBoard extends FlxSprite {
    public static inline final COLUMN_OFFSET = 7;
    public static inline final COLUMN_WIDTH = 48;
    public static inline final COLUMN_HEIGHT = 288;

    private var parent:PlayState;
    private var pieces:Array<Array<OmegaBoardPiece>> = [for (row in 0...BoardModel.ROWS) [for (col in 0...BoardModel.COLS) null]];

    override public function new(parent:PlayState, x:Float, y:Float) {
        super(x, y);

        this.parent = parent;

        loadGraphic("assets/images/board_omega.png");
    }

    public function setPiece(row:Int, column:Int, player:GameTurn) {
        pieces[row][column] = new OmegaBoardPiece(x + (column * COLUMN_WIDTH) + COLUMN_OFFSET, y + (row * COLUMN_WIDTH), player);
        parent.add(pieces[row][column]);
    }
}
