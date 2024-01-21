import utils.ReverseIntIterator;

enum BoardIndex {
    Alpha(index:Int);
    Omega;
}

enum BoardSlotType {
    Empty;
    Blue;
    Red;
}

enum GameTurn {
    Blue;
    Red;
}

enum BoardMoveResult {
    Fail;
    Ok(index:BoardIndex, row:Int, column:Int);
    Tie(index:BoardIndex, row:Int, column:Int);
    Win(index:BoardIndex, row:Int, column:Int);
}

enum GameMoveResult {
    Fail;
    Ok(index:BoardIndex, row:Int, column:Int);
    AlphaTie(index:BoardIndex, row:Int, column:Int);
    AlphaWin(omegaRow:Int, omegaColumn:Int, alphaIndex:BoardIndex, alphaRow:Int, alphaColumn:Int);
    OmegaTie(omegaRow:Int, omegaColumn:Int, alphaIndex:BoardIndex, alphaRow:Int, alphaColumn:Int);
    OmegaWin(omegaRow:Int, omegaColumn:Int, alphaIndex:BoardIndex, alphaRow:Int, alphaColumn:Int);
}

enum WinConditionLines {
    Horizontal;
    Vertical;
    FirstDiagonal;
    SecondDiagonal;
}

class BoardModel {
    public static inline final ROWS = 6;
    public static inline final COLS = 7;

    private var index:BoardIndex;
    private var slots:Array<Array<BoardSlotType>> = [for (row in 0...ROWS) [for (col in 0...COLS) Empty]];

    public function new(index:BoardIndex) {
        this.index = index;
    }

    public function getAvailableColumns():Array<Int> {
        var array:Array<Int> = [];

        for (column in 0...COLS) {
            if (slots[0][column] == Empty) {
                array.push(column);
            }
        }

        return array;
    }

    public function getSlots() {
        return slots;
    }

    public function makeMove(turn:GameTurn, column:Int):BoardMoveResult {
        for (row in new ReverseIntIterator(ROWS, 0)) {
            if (slots[row][column] == Empty) {
                slots[row][column] = convertGameTurn(turn);

                if (checkWinCondition(turn, row, column)) {
                    resetBoard();
                    return Win(index, row, column);
                }

                if (checkTieCondition()) {
                    resetBoard();
                    return Tie(index, row, column);
                }

                return Ok(index, row, column);
            }
        }

        return Fail;
    }

    private function checkTieCondition():Bool {
        for (column in 0...COLS) {
            if (slots[0][column] == Empty) {
                return false;
            }
        }

        return true;
    }

    private function checkWinCondition(turn:GameTurn, row:Int, col:Int):Bool {
        var type = convertGameTurn(turn);

        for (line in WinConditionLines.createAll()) {
            var counter = 0;
            for (offset in -3...4) {
                var rowToCheck = row;
                var colToCheck = col;

                switch line {
                case Horizontal:
                    colToCheck += offset;
                case Vertical:
                    rowToCheck += offset;
                case FirstDiagonal:
                    rowToCheck += offset;
                    colToCheck += offset;
                case SecondDiagonal:
                    rowToCheck -= offset;
                    colToCheck += offset;
                }

                if (rowToCheck < 0 || rowToCheck >= ROWS) {
                    counter = 0;
                    continue;
                }

                if (colToCheck < 0 || colToCheck >= COLS) {
                    counter = 0;
                    continue;
                }

                if (slots[rowToCheck][colToCheck] == type) {
                    counter++;
                    if (counter >= 4) {
                        return true;
                    }
                } else {
                    counter = 0;
                }
            }
        }

        return false;
    }

    private function convertGameTurn(turn:GameTurn):BoardSlotType {
        switch turn {
        case Blue:
            return Blue;
        case Red:
            return Red;
        }
    }

    private function resetBoard() {
        for (row in 0...ROWS) {
            for (col in 0...COLS) {
                slots[row][col] = Empty;
            }
        }
    }
}

class GameModel {
    public static inline final BOARDS = BoardModel.COLS;

    private var alphaBoards:Array<BoardModel> = [for (board in 0...BOARDS) new BoardModel(Alpha(board))];
    private var omegaBoard:BoardModel = new BoardModel(Omega);
    private var currentTurn:GameTurn = Blue;
    private var availableAlphaBoards:Array<Int>;

    public function new() {
        availableAlphaBoards = calculateAvailableAlphaBoard();
    }

    public function getCurrentTurn():GameTurn {
        return currentTurn;
    }

    public function getAvailableAlphaBoards():Array<Int> {
        return availableAlphaBoards;
    }

    public function getAvailableColumsInAlphaBoard(index:Int):Array<Int> {
        return alphaBoards[index].getAvailableColumns();
    }

    public function getAlphaBoard(boardIndex:Int):Array<Array<BoardSlotType>> {
        return alphaBoards[boardIndex].getSlots();
    }

    public function getOmegaBoard():Array<Array<BoardSlotType>> {
        return omegaBoard.getSlots();
    }

    public function makeMove(boardIndex:Int, column:Int):GameMoveResult {
        if (boardIndex < 0 || boardIndex >= BOARDS) {
            trace('boardIndex: $boardIndex out of range');

            return Fail;
        }

        if (!availableAlphaBoards.contains(boardIndex)) {
            trace('`availableAlphaBoards`: $availableAlphaBoards does not contain `boardIndex`: $boardIndex');

            return Fail;
        }

        switch alphaBoards[boardIndex].makeMove(currentTurn, column) {
        case Fail:
            trace('Alpha: `Fail`');

            return Fail;
        case Ok(index, row, column):
            availableAlphaBoards = calculateAvailableAlphaBoardFromIndex(column);
            switchTurn();

            return Ok(index, row, column);
        case Tie(index, row, colum):
            availableAlphaBoards = calculateAvailableAlphaBoardFromIndex(column);
            switchTurn();

            return AlphaTie(index, row, column);
        case Win(index, row, column):
            switch omegaBoard.makeMove(currentTurn, boardIndex) {
            case Fail:
                trace('ERROR: Alpha: `Win($index, $row, $column)`, lead to Omega: `Fail`');

                return Fail;
            case Ok(_, omegaRow, omegaColumn):
                availableAlphaBoards = calculateAvailableAlphaBoard();
                switchTurn();

                return AlphaWin(omegaRow, omegaColumn, index, row, column);
            case Tie(_, omegaRow, omegaColumn):
                availableAlphaBoards = [];

                return OmegaTie(omegaRow, omegaColumn, index, row, column);
            case Win(_, omegaRow, omegaColumn):
                availableAlphaBoards = [];

                return OmegaWin(omegaRow, omegaColumn, index, row, column);
            }
        }
    }

    private function calculateAvailableAlphaBoard():Array<Int> {
        var array:Array<Int> = [];

        for (column in 0...BoardModel.COLS) {
            if (omegaBoard.getSlots()[0][column] == Empty) {
                array.push(column);
            }
        }

        return array;
    }

    private function calculateAvailableAlphaBoardFromIndex(index:Int):Array<Int> {
        var array:Array<Int> = [];

        if (omegaBoard.getSlots()[0][index] == Empty) {
            array = [index];
        } else {
            array = calculateAvailableAlphaBoard();
        }

        return array;
    }

    private function switchTurn() {
        switch currentTurn {
        case Blue:
            currentTurn = Red;
        case Red:
            currentTurn = Blue;
        }
    }
}
