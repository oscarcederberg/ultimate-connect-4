package;

import GameModel.BoardModel;
import flixel.FlxSprite;
import flixel.FlxState;

enum PlayerType {
    Human;
    Computer;
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
        animation.play("on");
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

    override public function create() {
        super.create();

        bluePlayerType = Computer;
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

        if (bluePlayerType == Computer) {
            ComputerPlayer.generateMove(this, gameModel);
        }
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
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
                return;
            case Omega:
                trace('ERROR: gameModel.makeMove returned `OmegaWin($index, $row, $column)`');
                return;
            }
        }

        switch gameModel.getCurrentTurnType() {
        case Any:
            for (highlight in highlights) {
                highlight.animation.play("on");
            }
        case Board(index):
            for (highlight in highlights) {
                highlight.animation.play("off");
            }
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
}
