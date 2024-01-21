package;

import GameModel.BoardModel;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxTimer;

enum PlayerType {
    Human;
    Computer;
}

enum GameResult {
    BlueWin;
    RedWin;
    Tie;
}

class Highlight extends FlxSprite {
    override public function new(x:Float, y:Float) {
        super(x, y);

        loadGraphic("assets/images/highlight.png", true, 78, 78);
        animation.add("off", [0]);
        animation.add("on", [1]);
        animation.play("on");
    }
}

class PlayerTurnMarker extends FlxSprite {
    override public function new(x:Float, y:Float) {
        super(x, y);

        loadGraphic("assets/images/player_turn.png", true, 96, 48);
        animation.add("blue", [0]);
        animation.add("red", [1]);
        animation.play("blue");
    }
}

class GameResultMarker extends FlxSprite {
    override public function new(x:Float, y:Float, result:GameResult) {
        super(x, y);

        loadGraphic("assets/images/game_result_marker.png", true, 416, 192);
        animation.add("blue_win", [0]);
        animation.add("red_win", [1]);
        animation.add("tie", [2]);

        switch result {
        case BlueWin:
            animation.play("blue_win");
        case RedWin:
            animation.play("red_win");
        case Tie:
            animation.play("tie");
        }
    }
}

class PlayState extends FlxState {
    var gameModel:GameModel = new GameModel();
    var bluePlayerType:PlayerType;
    var redPlayerType:PlayerType;
    var alphaBoards:Array<AlphaBoard> = [for (board in 0...BoardModel.COLS) null];
    var omegaBoard:OmegaBoard;
    var highlights:Array<Highlight> = [for (board in 0...BoardModel.COLS) null];
    var omegaMarker:FlxSprite;
    var playerTurnMarker:PlayerTurnMarker;
    var gameResultMarker:GameResultMarker;
    var finished:Bool = false;

    override public function create() {
        super.create();

        bluePlayerType = Human;
        redPlayerType = Computer;

        for (index in 0...BoardModel.COLS) {
            this.highlights[index] = new Highlight(37 + (index * 82) - 2, 48 - 9);
            add(this.highlights[index]);
        }

        for (index in 0...BoardModel.COLS) {
            this.alphaBoards[index] = new AlphaBoard(this, index, 37 + (index * 82), 48);
            add(this.alphaBoards[index]);
        }

        omegaBoard = new OmegaBoard(this, 144, 147);
        add(omegaBoard);

        omegaMarker = new FlxSprite(112, 416, "assets/images/omega_marker.png");
        add(omegaMarker);

        playerTurnMarker = new PlayerTurnMarker(544, 432);
        add(playerTurnMarker);

        FlxG.autoPause = false;
        if (bluePlayerType == Computer) {
            ComputerPlayer.generateMove(this, gameModel);
        }
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        checkInteraction();
    }

    private function checkInteraction() {
        var player = gameModel.getCurrentTurn();

        if (!finished
            && FlxG.mouse.justPressed
            && (player == Blue && bluePlayerType == Human)
            || (player == Red && redPlayerType == Human)) {
            for (board in alphaBoards) {
                if (!gameModel.getAvailableAlphaBoards().contains(board.getIndex())) {
                    continue;
                }

                switch board.checkInteraction() {
                case Some(column):
                    makeMove(board.getIndex(), column);
                    break;
                case None:
                }
            }
        }
    }

    public function makeMove(index:Int, column:Int) {
        var player = gameModel.getCurrentTurn();

        switch gameModel.makeMove(index, column) {
        case Fail:
            return;
        case Ok(index, row, column):
            switch index {
            case Alpha(index):
                alphaBoards[index].setPiece(row, column, player);
            case Omega:
                trace('ERROR: gameModel.makeMove returned `Ok($index, $row, $column)`');
                return;
            }
        case AlphaTie(index, row, column):
            switch index {
            case Alpha(index):
                alphaBoards[index].resetPieces();
            case Omega:
                trace('ERROR: gameModel.makeMove returned `AlphaTie($index, $row, $column)`');
                return;
            }
        case OmegaTie(omegaRow, omegaColumn, index, row, column):
            switch index {
            case Alpha(index):
                alphaBoards[index].resetPieces();
                omegaBoard.setPiece(omegaRow, omegaColumn, player);
                trace("Tie!");
                endGame(Tie);
                return;
            case Omega:
                trace('ERROR: gameModel.makeMove returned `OmegaTie($index, $row, $column)`');
                return;
            }
        case AlphaWin(omegaRow, omegaColumn, index, row, column):
            switch index {
            case Alpha(index):
                alphaBoards[index].resetPieces();
                omegaBoard.setPiece(omegaRow, omegaColumn, player);
            case Omega:
                trace('ERROR: gameModel.makeMove returned `AlphaWin($index, $row, $column)`');
                return;
            }
        case OmegaWin(omegaRow, omegaColumn, index, row, column):
            switch index {
            case Alpha(index):
                alphaBoards[index].resetPieces();
                omegaBoard.setPiece(omegaRow, omegaColumn, player);
                trace('${player.getName()} wins!');
                endGame(switch player {
                case Blue:
                    BlueWin;
                case Red:
                    RedWin;
                });
                return;
            case Omega:
                trace('ERROR: gameModel.makeMove returned `OmegaWin($index, $row, $column)`');
                return;
            }
        }

        for (highlight in highlights) {
            highlight.animation.play("off");
        }

        for (index in gameModel.getAvailableAlphaBoards()) {
            highlights[index].animation.play("on");
        }

        switch gameModel.getCurrentTurn() {
        case Blue:
            playerTurnMarker.animation.play("blue");
            if (bluePlayerType == Computer) {
                ComputerPlayer.generateMove(this, gameModel);
            }
        case Red:
            playerTurnMarker.animation.play("red");
            if (redPlayerType == Computer) {
                ComputerPlayer.generateMove(this, gameModel);
            }
        }
    }

    private function endGame(result:GameResult) {
        for (highlight in highlights) {
            highlight.animation.play("off");
        }

        playerTurnMarker.destroy();

        gameResultMarker = new GameResultMarker(112, 144, result);
        add(gameResultMarker);

        var timer = new FlxTimer();
        timer.start(1, _ -> {
            FlxG.resetState();
        });
    }
}
