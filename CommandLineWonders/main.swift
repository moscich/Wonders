import Foundation
import Wonders_Mac

class StandardOutput: StringOutput {
    func print(_ string: String) {
        Swift.print(string)
    }
}

class ConsoleInteractor: PlayerInteractor {
    let name: String
    init(name: String) {
        self.name = name
    }
    func requestAction(game: Game, action: @escaping (Action) -> ()) {
        let presenter = OptionsPresenter(game: game, output: StandardOutput(), boardPresenter: DefaultBoardPresenter(board: game.board, output: StandardOutput()))
        var string: String
        repeat {
            print("player = \(name)")
            string = readLine()!
            if let commandLineAction = presenter.action(for: string) {
                action(commandLineAction)
                break
            }
        } while true
    }
}

let consoleInteractor1 = ConsoleInteractor(name: "First")
let consoleInteractor2 = ConsoleInteractor(name: "Second")
let game = Game(player1: consoleInteractor1, player2: consoleInteractor2)
