public class Military {
    var position = 0
    enum Event: Equatable {
        case takeGold(Int)
        case militaryWin
    }
    
    private var players: [(Player, Int)]
    private var events: [(Event, Int, Player)]
    init(player1: Player, player2: Player) {
        players = [(player1, 0), (player2, 0)]
        
        events = [
            (Event.takeGold(2), 3, player1),
            (Event.takeGold(5), 6, player1),
            (Event.takeGold(2), 3, player2),
            (Event.takeGold(5), 6, player2),
            (Event.militaryWin, 9, player1),
            (Event.militaryWin, 9, player2)
        ]
    }
    
    func playerPosition(_ player: Player) -> Int {
        return players.filter { arg -> Bool in
            player === arg.0
            }.first!.1
    }
    
    func claimPendingEvent() -> Event? {
        let player = position > 0 ? players[0].0 : players[1].0
        
            if let index = (events.index { event -> Bool in
                event.2 === player &&
                    abs(position) >= event.1
            }) {
                let event = events[index].0
                events.remove(at: index)
                return event
            }
        
        return nil
    }
    
    func move(player: Player, fields: Int) {
        if player === players.first!.0 {
            position += fields
        } else {
            position -= fields
        }
    }
}
