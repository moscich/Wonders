import XCTest
@testable import Wonders

class GameTests: XCTestCase {
    var player1Interactor = TestPlayerInteractor()
    var player2Interactor = TestPlayerInteractor()
    
    override func setUp() {
        super.setUp()
        
        player1Interactor = TestPlayerInteractor()
        player2Interactor = TestPlayerInteractor()
    }
    
    func testAskFirstInteractorForAction() {
        _ = Game(player1: player1Interactor, player2: TestPlayerInteractor())
        XCTAssertTrue(player1Interactor.wasAskedForAction)
    }
    
    func testCardTakeAction() {
        let testCard = TestCard(cost: Resource(wood: 1))
        let testBoard = Board(cards: [CardOnBoard(card: testCard, hidden: false, descendants: [])])
        
        let game = Game(player1: player1Interactor, player2: player2Interactor, boardFactory: TestBoardFactory(board: testBoard))
        
        player1Interactor.receivedSomePlayerInteraction(interaction: .takeCard(testCard))
        XCTAssertEqual(game.player1.cards.count, 1)
        XCTAssertEqual(game.player1.gold, 4)
        XCTAssertTrue(game.board.availableCards.isEmpty)
    }
    //
    func testCardTakeAction_v2() {
        let testCard = TestCard(cost: Resource(wood: 2))
        let testBoard = Board(cards: [CardOnBoard(card: testCard, hidden: false, descendants: [])])
        
        let game = Game(player1: player1Interactor, player2: player2Interactor, boardFactory: TestBoardFactory(board: testBoard))
        
        player1Interactor.receivedSomePlayerInteraction(interaction: .takeCard(testCard))
        XCTAssertEqual(game.player1.cards.count, 1)
        XCTAssertEqual(game.player1.gold, 2)
        XCTAssertTrue(game.board.availableCards.isEmpty)
    }
    
    func testCardOnePlayerAfterAnother() {
        let testCard = TestCard(cost: Resource(wood: 2))
        let testCard2 = TestCard(cost: Resource(stones: 1))
        let cards = [CardOnBoard(card: testCard, hidden: false, descendants: []),
                     CardOnBoard(card: testCard2, hidden: false, descendants: [])]
        let testBoard = Board(cards: cards)
        let game = Game(player1: player1Interactor, player2: player2Interactor, boardFactory: TestBoardFactory(board: testBoard))
        
        player1Interactor.receivedSomePlayerInteraction(interaction: .takeCard(testCard))
        XCTAssertEqual(game.player1.cards.count, 1)
        XCTAssertEqual(game.player1.gold, 2)
        XCTAssertEqual(game.board.availableCards.count, 1)
        
        player2Interactor.receivedSomePlayerInteraction(interaction: .takeCard(testCard2))
        XCTAssertEqual(game.player2.cards.count, 1)
        XCTAssertEqual(game.player2.gold, 4)
        XCTAssertTrue(game.board.availableCards.isEmpty)
    }
    
    func testTryTakeTooExpensiveCard() {
        let testCard = TestCard(cost: Resource(wood: 4))
        let testBoard = Board(cards: [CardOnBoard(card: testCard, hidden: false, descendants: [])])
        
        let game = Game(player1: player1Interactor, player2: player2Interactor, boardFactory: TestBoardFactory(board: testBoard))
        
        player1Interactor.wasAskedForAction = false
        player1Interactor.receivedSomePlayerInteraction(interaction: .takeCard(testCard))
        XCTAssertEqual(game.player1.cards.count, 0)
        XCTAssertEqual(game.player1.gold, 6)
        XCTAssertEqual(game.board.availableCards.count, 1)
        XCTAssertTrue(player1Interactor.wasAskedForAction)
    }
    
    func testSellCardAction() {
        let testCard = TestCard(cost: Resource(wood: 4))
        let testBoard = Board(cards: [CardOnBoard(card: testCard, hidden: false, descendants: [])])
        
        let game = Game(player1: player1Interactor, player2: player2Interactor, boardFactory: TestBoardFactory(board: testBoard))
        
        player1Interactor.receivedSomePlayerInteraction(interaction: .sellCard(testCard))
        XCTAssertEqual(game.player1.cards.count, 0)
        XCTAssertEqual(game.player1.gold, 8)
        XCTAssertTrue(game.board.availableCards.isEmpty)
        XCTAssertTrue(player2Interactor.wasAskedForAction)
    }
    
    func testBuildWonderAction() {
        let testBoard = Board(cards: [CardOnBoard(name: "Test")])
        let reqRes = Resource(wood: 1, stones: 2, clay: 3, glass: 4, papyrus: 5, gold: 2)
        let calc = MockCalculator(resource: reqRes)
        let shop = MockShop(cost: 4)
        let game = Game(player1: player1Interactor, player2: player2Interactor, boardFactory: TestBoardFactory(board: testBoard), resourceCalculator: calc, shop: shop)
        let wonder = game.player1.wonders.first!
        player1Interactor.receivedSomePlayerInteraction(interaction: .buildWonder(wonder, testBoard.availableCards.first!))
        XCTAssertTrue(game.board.availableCards.isEmpty)
        XCTAssertTrue(wonder.built)
        XCTAssertEqual(game.player1.gold, 2)
    }
    
    func testTooExpensiveWonderAction() {
        let testBoard = Board(cards: [CardOnBoard(name: "Test")])
        let reqRes = Resource(wood: 1, stones: 2, clay: 3, glass: 4, papyrus: 5, gold: 2)
        let calc = MockCalculator(resource: reqRes)
        let shop = MockShop(cost: 8)
        let game = Game(player1: player1Interactor, player2: player2Interactor, boardFactory: TestBoardFactory(board: testBoard), resourceCalculator: calc, shop: shop)
        let wonder = game.player1.wonders.first!
        player1Interactor.receivedSomePlayerInteraction(interaction: .buildWonder(wonder, testBoard.availableCards.first!))
        XCTAssertEqual(game.board.availableCards.count, 1)
        XCTAssertFalse(wonder.built)
        XCTAssertEqual(game.player1.gold, 6)
    }
    
    func testViaAppiaWonder() {
        let testBoard = Board(cards: [CardOnBoard(name: "Test")])
        let reqRes = Resource(wood: 1, stones: 2, clay: 3, glass: 4, papyrus: 5, gold: 2)
        let calc = MockCalculator(resource: reqRes)
//        let game = Game(player1: player1Interactor, player2: player2Interactor, boardFactory: TestBoardFactory(board: testBoard), resourceCalculator: calc, shop: shop)
        
    }
}

class MockShop: Shop {
    var wonder: Wonder?
    var player: Player?
    func wonderCost(_ wonder: Wonder, for player: Player) -> Int {
        self.wonder = wonder
        self.player = player
        return cost
    }
    
    var cost: Int
    init(cost: Int) {
        self.cost = cost
    }
    var checkForResource = Resource()
    func resourceCost(_ resource: Resource, player: Player?, oponentResource: Resource) -> Int {
        checkForResource = resource
        return cost
    }
}

class MockCalculator: ResourceCalculator {
    let resource: Resource
    
    init(resource: Resource) {
        self.resource = resource
    }
    
    func concreteResources(in cards: [Card]) -> Resource {
        return resource
    }
    
    func requiredResources(for card: Card, player: Player) -> Resource {
        return resource
    }
    
    
}
