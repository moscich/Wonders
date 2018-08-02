import Foundation
import Wonders_Mac

protocol StringOutput {
    func print(_ string: String)
}

class BoardPresenter {
    let output: StringOutput
    let board: Board
    
    init(board: Board, output: StringOutput) {
        self.output = output
        self.board = board
    }
    
    func showAvailableCards() {
        if board.cards.isEmpty {
            output.print("No Cards")
            return
        }
        for (index, boardCard) in board.cards.enumerated() {
            if let card = boardCard?.card {
                output.print("\(index + 1). \(card.name)")
            }
        }
    }
}
