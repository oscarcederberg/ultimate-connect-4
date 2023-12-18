import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxSpriteGroup;
import utils.AttachableSprite;
import utils.Hitbox;
import utils.ReverseIntIterator;

enum BoardTurn {
    Blue;
    Red;
}

enum BoardSlotType {
    Empty;
    Blue;
    Red;
}

class BoardSlot extends AttachableSprite {
    public static inline final SIZE = 48;

    private var type:BoardSlotType = Empty;

    override public function new(x:Float, y:Float) {
        super(x, y);

        loadGraphic("assets/images/board_slot.png", true, SIZE, SIZE);
        animation.add("empty", [0]);
        animation.add("blue", [1]);
        animation.add("red", [2]);
        animation.play("empty");
    }

    public function getSlotType():BoardSlotType {
        return type;
    }

    public function setSlotType(turn:BoardTurn) {
        switch turn {
        case Blue:
            this.type = Blue;
            animation.play("blue");
        case Red:
            this.type = Red;
            animation.play("red");
        }
    }
}

class BoardColumnHitbox extends Hitbox {
    public var columnIndex:Int;

    override public function new(columnIndex:Int, parent:FlxObject, x:Int, y:Int) {
        super(parent, x, y, BoardSlot.SIZE, Board.COLS * BoardSlot.SIZE);

        this.columnIndex = columnIndex;
    }
}

class Board extends FlxSpriteGroup {
    public static inline final ROWS = 6;
    public static inline final COLS = 7;

    private var slots:Array<Array<BoardSlot>> = [for (row in 0...ROWS) [for (col in 0...COLS) null]];
    private var columnHitboxes:Array<BoardColumnHitbox> = [for (row in 0...ROWS) null];
    private var turn:BoardTurn = Blue;

    override public function new(x:Float, y:Float) {
        super();

        this.setPosition(x, y);
        makeGraphic(336, 288);

        for (row in 0...ROWS) {
            for (col in 0...COLS) {
                var slot = new BoardSlot(x + col * BoardSlot.SIZE, y + row * BoardSlot.SIZE);

                slot.attach(this, col * BoardSlot.SIZE, row * BoardSlot.SIZE);
                slots[row][col] = slot;
                add(slot);
            }
        }

        for (col in 0...COLS) {
            columnHitboxes[col] = new BoardColumnHitbox(col, this, col * BoardSlot.SIZE, 0);
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        for (hitbox in columnHitboxes) {
            if (hitbox.overlapsPoint(FlxG.mouse.getPosition())) {
                if (FlxG.mouse.justPressed) {
                    makeMove(hitbox.columnIndex);
                }
                break;
            }
        }
    }

    private function makeMove(col:Int) {
        for (row in new ReverseIntIterator(ROWS, 0)) {
            if (slots[row][col].getSlotType() == Empty) {
                slots[row][col].setSlotType(turn);

                switch turn {
                case Blue:
                    this.turn = Red;
                case Red:
                    this.turn = Blue;
                }
                break;
            }
        }
    }
}
