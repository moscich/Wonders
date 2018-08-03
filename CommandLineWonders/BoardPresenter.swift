import Foundation
import Wonders_Mac

let welcomeMessage = "Hello! Options:\ncard: Take available card"
let unknownActionMessage = "Error Unrecognized command"

protocol StringOutput {
    func print(_ string: String)
}

protocol StringCommandHandler {
    func command(_ command: String, action: @escaping (Action) -> ())
}

protocol BoardPresenter: StringCommandHandler {
    func presentAvailableCards()
    func getCard(index: UInt8) -> Card?
}

class DefaultBoardPresenter: BoardPresenter {
    func command(_ command: String, action: @escaping (Action) -> ()) {
        action(CardTakeAction(requestedCard: getCard(index: UInt8(command)! - 1)!))
    }
    
    func getCard(index: UInt8) -> Card? {
        if board.availableCards.count > index {
            return board.availableCards[Int(index)]
        }
        return nil
    }
    
    func presentAvailableCards() {
        for (index, card) in board.availableCards.enumerated() {
            output.print("\(index + 1). \(card.name)")
        }
    }
    
    let output: StringOutput
    let board: Board
    
    init(board: Board, output: StringOutput) {
        self.output = output
        self.board = board
    }
    
}
