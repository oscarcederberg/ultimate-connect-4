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

    public function isPlayerPiece(player:BoardTurn):Bool {
        switch type {
        case Empty:
            return false;
        case Blue:
            if (player == Blue) {
                return true;
            } else {
                return false;
            }
        case Red:
            if (player == Red) {
                return true;
            } else {
                return false;
            }
        }
    }

    public function getSlotType():BoardSlotType {
        return type;
    }

    public function resetSlot() {
        this.type = Empty;
        animation.play("empty");
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
    private var locked:Bool = false;

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

    private function checkWinCondition(turn:BoardTurn, row:Int, col:Int):Bool {
        // check horizontally
        var counter = 0;
        for (offset in -3...4) {
            var colToCheck = col + offset;
            trace('row, col: (${row}, ${colToCheck})');

            if (colToCheck < 0 || colToCheck >= COLS) {
                counter = 0;
                continue;
            }

            if (slots[row][colToCheck].isPlayerPiece(turn)) {
                counter++;
                if (counter >= 4) {
                    return true;
                }
            } else {
                counter = 0;
            }
        }

        // check vertically
        counter = 0;
        for (offset in -3...4) {
            var rowToCheck = row + offset;
            trace('row, col: (${rowToCheck}, ${col})');

            if (rowToCheck < 0 || rowToCheck >= ROWS) {
                counter = 0;
                continue;
            }

            if (slots[rowToCheck][col].isPlayerPiece(turn)) {
                counter++;
                if (counter >= 4) {
                    return true;
                }
            } else {
                counter = 0;
            }
        }

        // check first diagonal
        counter = 0;
        for (offset in -3...4) {
            var rowToCheck = row + offset;
            var colToCheck = col + offset;
            trace('row, col: (${rowToCheck}, ${colToCheck})');

            if (rowToCheck < 0 || rowToCheck >= ROWS) {
                counter = 0;
                continue;
            }

            if (colToCheck < 0 || colToCheck >= COLS) {
                counter = 0;
                continue;
            }

            if (slots[rowToCheck][colToCheck].isPlayerPiece(turn)) {
                counter++;
                if (counter >= 4) {
                    return true;
                }
            } else {
                counter = 0;
            }
        }

        // check second diagonal
        counter = 0;
        for (offset in -3...4) {
            var rowToCheck = row - offset;
            var colToCheck = col + offset;
            trace('row, col: (${rowToCheck}, ${colToCheck})');

            if (rowToCheck < 0 || rowToCheck >= ROWS) {
                counter = 0;
                continue;
            }

            if (colToCheck < 0 || colToCheck >= COLS) {
                counter = 0;
                continue;
            }

            if (slots[rowToCheck][colToCheck].isPlayerPiece(turn)) {
                counter++;
                if (counter >= 4) {
                    return true;
                }
            } else {
                counter = 0;
            }
        }

        return false;
    }

    private function makeMove(col:Int) {
        for (row in new ReverseIntIterator(ROWS, 0)) {
            if (slots[row][col].getSlotType() == Empty) {
                slots[row][col].setSlotType(turn);
                if (checkWinCondition(turn, row, col)) {
                    trace("win!");
                    resetBoard();
                }

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

    private function resetBoard() {
        for (row in 0...ROWS) {
            for (col in 0...COLS) {
                slots[row][col].resetSlot();
            }
        }
    }
}
