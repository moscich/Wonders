import Foundation
import Wonders_Mac

class ConsoleInteractor: PlayerInteractor {
    func requestAction(game: Game, action: @escaping (Action) -> ()) {
        print("choose action")
        let string = readLine()
        
//        action(CardTakeAction(requestedCardNo: Int(string!)!))
    }
}

let dispatchGroup = DispatchGroup()
dispatchGroup.enter()
let consoleInteractor = ConsoleInteractor()
let game = Game(player1: consoleInteractor, player2: consoleInteractor)
