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
    
    func command(_ command: String, action: @escaping (Action) -> ()) {
        guard currentCommandHandler == nil else { currentCommandHandler?.command(command, action: action); return }
        if command == "card" {
            boardPresenter.presentAvailableCards()
            currentCommandHandler = boardPresenter
        } else {
            output.print(unknownActionMessage)
        }
    }
}
