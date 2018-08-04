import Foundation
import Wonders_Mac

let welcomeMessage = "Hello! "
let unknownActionMessage = "Error Unrecognized command"

protocol StringOutput {
    func print(_ string: String)
}

protocol StringCommandHandler {
    func command(_ command: String, action: @escaping (Action) -> ()) -> Bool
}

protocol BoardPresenter: StringCommandHandler {
    func presentAvailableCards()
    func getCard(index: UInt8) -> Card?
    var availableCards: String { get }
}

class DefaultBoardPresenter: BoardPresenter {
    func command(_ command: String, action: @escaping (Action) -> ()) -> Bool {
        action(CardTakeAction(requestedCard: getCard(index: UInt8(command)! - 1)!))
        return true
    }
    
    func getCard(index: UInt8) -> Card? {
        if board.availableCards.count > index {
            return board.availableCards[Int(index)]
        }
        return nil
    }
    
    var availableCards: String {
        var result = ""
        for (index, card) in board.availableCards.enumerated() {
            result += "\(index + 1). \(card.name)"
            if index < board.availableCards.count - 1 {
                result += "\n"
            }
        }
        return result
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
