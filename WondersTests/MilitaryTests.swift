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
        XCTAssertEqual(military.playerPosition(Player()), 0)
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
        if case let Military.Event.takeGold(gold) = event {
            XCTAssertEqual(gold, 2)
        } else {
            XCTFail()
        }
    }
}

class Military {
    enum Event {
        case takeGold(Int)
    }
    let player1: Player
    let player2: Player
    var player1Points: Int = 0
    var player2Points: Int = 0
    
    init(player1: Player, player2: Player) {
        self.player1 = player1
        self.player2 = player2
    }
    
    func playerPosition(_ player: Player) -> Int {
        if player === player1 {
            return player1Points
        } else {
            return player2Points
        }
    }
    
    func move(player: Player, fields: Int) -> Event? {
        var event: Event?
        if player === player1 {
            player1Points += fields
            player2Points -= fields
            if player1Points > 2 {
                event = .takeGold(2)
            }
        } else {
            // tu też event.
            player2Points += fields
            player1Points -= fields
        }
        return event
    }
}
