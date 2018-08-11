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
        military.move(player: player1, fields: 1)
        XCTAssertEqual(military.position, 1)
        XCTAssertNil(military.claimPendingEvent())
        military.move(player: player2, fields: 1)
        XCTAssertEqual(military.position, 0)
        XCTAssertNil(military.claimPendingEvent())
    }
    
    func testMilitaryGoldEvent() {
        military.move(player: player1, fields: 3)
        let event = military.claimPendingEvent()
        AssertEventsEqual(event, .takeGold(2))
        XCTAssertNil(military.claimPendingEvent())
    }
    
    func testMilitaryGoldEventOnlyOncePerPlayer() {
        military.move(player: player1, fields: 3)
        _ = military.claimPendingEvent()
        military.move(player: player2, fields: 3)
        _ = military.claimPendingEvent()
        military.move(player: player1, fields: 3)
        let event = military.claimPendingEvent()
        XCTAssertNil(event)
    }
    
    func testAllEvents() {
        military.move(player: player1, fields: 3)
        var event = military.claimPendingEvent()
        AssertEventsEqual(event, .takeGold(2))
        military.move(player: player1, fields: 1)
        event = military.claimPendingEvent()
        XCTAssertNil(event)
        military.move(player: player1, fields: 2)
        event = military.claimPendingEvent()
        AssertEventsEqual(event, .takeGold(5))
        military.move(player: player2, fields: 2)
        event = military.claimPendingEvent()
        XCTAssertNil(event)
        military.move(player: player1, fields: 3)
        event = military.claimPendingEvent()
        XCTAssertNil(event)
        military.move(player: player1, fields: 2)
        event = military.claimPendingEvent()
        AssertEventsEqual(event, .militaryWin)
        military.move(player: player2, fields: 9)
        event = military.claimPendingEvent()
        XCTAssertNil(event)
        military.move(player: player2, fields: 3)
        event = military.claimPendingEvent()
        AssertEventsEqual(event, .takeGold(2))
        military.move(player: player2, fields: 3)
        event = military.claimPendingEvent()
        AssertEventsEqual(event, .takeGold(5))
        military.move(player: player2, fields: 3)
        event = military.claimPendingEvent()
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
