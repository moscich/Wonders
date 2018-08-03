import Foundation
import Wonders_Mac

class OptionsPresenter: StringCommandHandler {
    let game: Game
    let output: StringOutput
    let boardPresenter: BoardPresenter
    var currentCommandHandler: StringCommandHandler?
    init(game: Game, output: StringOutput, boardPresenter: BoardPresenter) {
        self.output = output
        self.game = game
        self.boardPresenter = boardPresenter
        output.print(welcomeMessage)
    }
    
    func command(_ command: String, action: @escaping (Action) -> ()) -> Bool {
        guard currentCommandHandler == nil else { return currentCommandHandler?.command(command, action: action) ?? false }
        if command == "card" {
            boardPresenter.presentAvailableCards()
            currentCommandHandler = boardPresenter
        } else {
            output.print(unknownActionMessage)
        }
        return false
    }
}
