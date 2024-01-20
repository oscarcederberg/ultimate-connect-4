import GameModel.BoardModel;
import GameModel.GameTurn;
import flixel.FlxG;
import flixel.FlxSprite;
import haxe.ds.Option;
import utils.Hitbox;

class AlphaBoardPiece extends FlxSprite {
    public static inline final SIZE = 10;

    override public function new(x:Float, y:Float, player:GameTurn) {
        super(x, y);

        loadGraphic("assets/images/piece_alpha.png", true, SIZE);
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

class AlphaBoardColumnHitbox extends Hitbox {
    private var index:Int;

    override public function new(index:Int, parent:AlphaBoard, x:Float, y:Float) {
        super(parent, x, y, AlphaBoard.COLUMN_WIDTH, AlphaBoard.COLUMN_HEIGHT);

        this.index = index;
    }

    public function getIndex():Int {
        return this.index;
    }
}

class AlphaBoard extends FlxSprite {
    public static inline final COLUMN_OFFSET = 2;
    public static inline final COLUMN_WIDTH = 10;
    public static inline final COLUMN_HEIGHT = 60;

    private var parent:PlayState;
    private var index:Int;
    private var pieces:Array<Array<AlphaBoardPiece>> = [for (row in 0...BoardModel.ROWS) [for (col in 0...BoardModel.COLS) null]];
    private var columnHitboxes:Array<AlphaBoardColumnHitbox> = [for (col in 0...BoardModel.COLS) null];

    override public function new(parent:PlayState, index:Int, x:Float, y:Float) {
        super(x, y);

        this.parent = parent;
        this.index = index;

        for (col in 0...BoardModel.COLS) {
            columnHitboxes[col] = new AlphaBoardColumnHitbox(col, this, (col * COLUMN_WIDTH) + COLUMN_OFFSET, 0);
        }

        loadGraphic("assets/images/board_alpha.png");
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        for (hitbox in columnHitboxes) {
            hitbox.update(elapsed);
        }
    }

    public function checkInteraction():Option<Int> {
        for (hitbox in columnHitboxes) {
            if (FlxG.mouse.justPressed && hitbox.overlapsPoint(FlxG.mouse.getPosition())) {
                return Some(hitbox.getIndex());
            }
        }

        return None;
    }

    public function resetPieces() {
        for (row in 0...BoardModel.ROWS) {
            for (col in 0...BoardModel.COLS) {
                if (pieces[row][col] != null) {
                    pieces[row][col].destroy();
                    pieces[row][col] = null;
                }
            }
        }
    }

    public function setPiece(row:Int, column:Int, player:GameTurn) {
        pieces[row][column] = new AlphaBoardPiece(x + (column * COLUMN_WIDTH) + COLUMN_OFFSET, y + (row * COLUMN_WIDTH), player);
        parent.add(pieces[row][column]);
    }

    public function getIndex():Int {
        return index;
    }
}
