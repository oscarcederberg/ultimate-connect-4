import flixel.math.FlxRandom;
import flixel.util.FlxTimer;

class ComputerPlayer {
    static public function generateMove(state:PlayState, model:GameModel) {
        var random = new FlxRandom();
        var timer = new FlxTimer();

        timer.start(random.float(1, 3), _ -> {
            var boardIndex = random.getObject(model.getAvailableAlphaBoards());
            var column = random.getObject(model.getAvailableColumsInAlphaBoard(boardIndex));

            state.makeMove(boardIndex, column);
        });
    }
}
