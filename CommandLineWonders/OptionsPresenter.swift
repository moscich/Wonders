import Foundation
import Wonders_Mac

protocol CardSeller: StringCommandHandler {
    
}

class DefaultCardSeller: CardSeller {
    func command(_ command: String, action: @escaping (Action) -> ()) -> Bool {
        return false 
    }
    
}

class OptionsPresenter: StringCommandHandler {
    let game: Game
    let output: StringOutput
    let boardPresenter: BoardPresenter
    var currentCommandHandler: StringCommandHandler?
    
    convenience init(game: Game, output: StringOutput) {
        self.init(game: game, output: output, boardPresenter: DefaultBoardPresenter(board: game.board, output: output))
    }
    
    init(game: Game, output: StringOutput, boardPresenter: BoardPresenter) {
        self.output = output
        self.game = game
        self.boardPresenter = boardPresenter
        output.print(welcomeMessage)
    }
    
    func action(for string: String) -> Action? {
        let split = string.split(separator: " ")
        if split[0] == "take" {
            let card = boardPresenter.getCard(index: UInt8(split[1])! - 1)
            return CardTakeAction(requestedCard: card!)
        } else if string == "list" {
            output.print(boardPresenter.availableCards)
        } else if split[0] == "sell" {
            let card = boardPresenter.getCard(index: UInt8(split[1])! - 1)
            return CardSellAction(requestedCard: card!)
        } else {
            output.print(unknownActionMessage)
        }
        return nil
    }
    
    func command(_ command: String, action: @escaping (Action) -> ()) -> Bool {
        guard currentCommandHandler == nil else { return currentCommandHandler?.command(command, action: action) ?? false }
        if command == "card" || command == "sell" {
            boardPresenter.presentAvailableCards()
            currentCommandHandler = boardPresenter
        } else {
            output.print(unknownActionMessage)
        }
        return false
    }
}

struct TestAction: Action {
    
}
