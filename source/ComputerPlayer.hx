import GameModel.BoardSlotType;
import flixel.math.FlxRandom;
import flixel.util.FlxTimer;

class ComputerPlayer {
    static public function generateMove(state:PlayState, model:GameModel) {
        var random = new FlxRandom();
        var timer = new FlxTimer();

        timer.start(random.float(0.01, 0.1), _ -> {
            var type = model.getCurrentTurnType();
            var boardIndex:Int = -1;
            var board:Array<Array<BoardSlotType>>;

            switch type {
            case Any:
                while (true) {
                    var index = random.int(0, 6);

                    if (model.getOmegaBoard()[0][index] == Empty) {
                        boardIndex = index;
                        break;
                    }
                }
            case Board(index):
                boardIndex = index;
            }

            board = model.getAlphaBoard(boardIndex);

            var column:Int = -1;
            while (true) {
                column = random.int(0, 6);
                if (board[0][column] == Empty) {
                    break;
                }
            }

            state.makeMove(boardIndex, column);
        });
    }
}
