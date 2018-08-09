import XCTest
@testable import Wonders

class MilitaryTests: XCTestCase {
    var player1 = Player()
    var player2 = Player()
    var military: Military!
    
    override func setUp() {
        super.setUp()
        military = Military(player1: player1, player2: player2)
    }
    
    func testStartingPosition(){
        XCTAssertEqual(military.playerPosition(player1), 0)
    }
    
    func testMoveOnePosition() {
        var event = military.move(player: player1, fields: 1)
        XCTAssertEqual(military.playerPosition(player1), 1)
        XCTAssertEqual(military.playerPosition(player2), -1)
        XCTAssertNil(event)
        event = military.move(player: player2, fields: 1)
        XCTAssertEqual(military.playerPosition(player1), 0)
        XCTAssertEqual(military.playerPosition(player2), 0)
        XCTAssertNil(event)
    }
    
    func testMilitaryGoldEvent() {
        guard let event = military.move(player: player1, fields: 3) else { XCTFail(); return }
        AssertEventsEqual(event, .takeGold(2))
    }
    
    func testMilitaryGoldEventOnlyOncePerPlayer() {
        _ = military.move(player: player1, fields: 3)
        _ = military.move(player: player2, fields: 3)
        let event = military.move(player: player1, fields: 3)
        XCTAssertNil(event)
    }
    
    func testAllEvents() {
        var event = military.move(player: player1, fields: 3)
        AssertEventsEqual(event, .takeGold(2))
        event = military.move(player: player1, fields: 1)
        XCTAssertNil(event)
        event = military.move(player: player1, fields: 2)
        AssertEventsEqual(event, .takeGold(5))
        event = military.move(player: player2, fields: 2)
        XCTAssertNil(event)
        event = military.move(player: player1, fields: 3)
        XCTAssertNil(event)
        event = military.move(player: player1, fields: 2)
        AssertEventsEqual(event, .militaryWin)
        event = military.move(player: player2, fields: 9)
        XCTAssertNil(event)
        event = military.move(player: player2, fields: 3)
        AssertEventsEqual(event, .takeGold(2))
        event = military.move(player: player2, fields: 3)
        AssertEventsEqual(event, .takeGold(5))
        event = military.move(player: player2, fields: 3)
        AssertEventsEqual(event, .militaryWin)
    }
}

func AssertEventsEqual(
    _ event1: Military.Event?, _ event2: Military.Event,
    file: StaticString = #file, line: UInt = #line
    ) {
    if let event1 = event1 {
        XCTAssertEqual(event1, event2, file: file, line: line)
    } else {
        XCTFail("Expected Not Nil", file: file, line: line)
    }
}

class Military {
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
    
    func move(player: Player, fields: Int) -> Event? {
        guard let index = (players.firstIndex { (playerInner, points) -> Bool in
            player === playerInner
        }) else { return nil }
        let opponentIndex = index == 0 ? 1 : 0
        
        players[index] = (players[index].0, players[index].1 + fields)
        players[opponentIndex] = (players[opponentIndex].0, players[opponentIndex].1 - fields)
        
        if let index = (events.firstIndex { event -> Bool in
            event.2 === players[index].0 &&
                players[index].1 >= event.1
        }) {
            let event = events[index].0
            events.remove(at: index)
            return event
        }

        return nil
    }
}
