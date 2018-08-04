import Foundation
import Wonders_Mac

class StandardOutput: StringOutput {
    func print(_ string: String) {
        Swift.print(string)
    }
}

class ConsoleInteractor: PlayerInteractor {
    func requestAction(game: Game, action: @escaping (Action) -> ()) {
        let presenter = OptionsPresenter(game: game, output: StandardOutput(), boardPresenter: DefaultBoardPresenter(board: game.board, output: StandardOutput()))
        var string: String
        repeat {
            string = readLine()!
        } while !presenter.command(string, action: action)
    }
}

let consoleInteractor = ConsoleInteractor()
let game = Game(player1: consoleInteractor, player2: consoleInteractor)
