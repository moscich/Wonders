import XCTest
@testable import Wonders

class ShopTests: XCTestCase {
    
    func testOneWoodCost_noCards() {
        let shop = Shop()
        let cost = shop.resourceCost(Resource(wood: 1), oponentResource: Resource())
        XCTAssertEqual(cost, 2)
    }
    
    func testOneWoodOneClayCost_noCards() {
        let shop = Shop()
        let cost = shop.resourceCost(Resource(wood: 1, clay: 1), oponentResource: Resource())
        XCTAssertEqual(cost, 4)
    }
    
    func testOneWood_OpponentHas1Wood() {
        let shop = Shop()
        let cost = shop.resourceCost(Resource(wood: 1), oponentResource: Resource(wood: 1))
        XCTAssertEqual(cost, 3)
    }
    
    func testOneOfEach_OpponentHas1Wood2stones3papyrus4clay5glass() {
        let shop = Shop()
        let cost = shop.resourceCost(Resource(wood: 1, stones: 1, clay: 1, glass: 1, papyrus: 1), oponentResource: Resource(wood: 1, stones: 2, clay: 3, glass: 4, papyrus: 5))
        XCTAssertEqual(cost, 25)
    }
}

class ResourceCalculatorTests: XCTestCase {
    func testResourceSummary() {
        let calculator = ResourceCalculator()
        let woodCard = Card(name: "", cost: Resource(), providedResource: Resource(wood: 2))
        let clayCard = Card(name: "", cost: Resource(), providedResource: Resource(clay: 1))
        let resources = calculator.concreteResources(in: [woodCard, clayCard])
        XCTAssertEqual(resources, Resource(wood: 2, clay: 1))
    }
    
    func testRequiredResources() {
        let calculator = ResourceCalculator()
        let card = Card(name: "", cost: Resource(wood: 1, stones: 3, clay: 2), providedResource: Resource())
        let player1 = Player()
        player1.cards = [Card(name: "", cost: Resource(), providedResource: Resource(wood: 3, stones: 1))]
        let requiredResources = calculator.requiredResources(for: card, player: player1)
        XCTAssertEqual(requiredResources, Resource(stones: 2, clay: 2))
    }
}

class GameTests: XCTestCase {
    func testAskFirstInteractorForAction() {
        let playerInteractor = TestPlayerInteractor()
        _ = Game(player1: playerInteractor, player2: TestPlayerInteractor())
        XCTAssertTrue(playerInteractor.wasAskedForAction)
    }
    
    func testPlayersTakeActionsOneAfterAnother() {
        let player1Interactor = TestPlayerInteractor()
        let player2Interactor = TestPlayerInteractor()
        let game = Game(player1: player1Interactor, player2: player2Interactor)
        XCTAssertTrue(player1Interactor.wasAskedForAction)
        XCTAssertFalse(player2Interactor.wasAskedForAction)
        player1Interactor.receivedSomePlayerInteraction(interaction: TestAction())
        XCTAssertTrue(player2Interactor.wasAskedForAction)

        player1Interactor.wasAskedForAction = false
        player2Interactor.wasAskedForAction = false

        player2Interactor.receivedSomePlayerInteraction(interaction: TestAction())

        XCTAssertTrue(player1Interactor.wasAskedForAction)
        print(game)
    }
    
    func testCardTakeAction() {
        let player1Interactor = TestPlayerInteractor()
        let player2Interactor = TestPlayerInteractor()
        let testCard = Card(name: "", cost: Resource(wood: 1), providedResource: Resource())
        let testBoard = Board(cards: [CardOnBoard(card: testCard, hidden: false, descendants: [])])
        
        let game = Game(player1: player1Interactor, player2: player2Interactor, boardFactory: TestBoardFactory(board: testBoard))

        player1Interactor.receivedSomePlayerInteraction(interaction: CardTakeAction(requestedCard: testCard))
        XCTAssertEqual(game.player1.cards.count, 1)
        XCTAssertEqual(game.player1.gold, 4)
        XCTAssertTrue(game.board.availableCards.isEmpty)
    }
//
    func testCardTakeAction_v2() {
        let player1Interactor = TestPlayerInteractor()
        let player2Interactor = TestPlayerInteractor()
        let testCard = Card(name: "", cost: Resource(wood: 2), providedResource: Resource())
        let testBoard = Board(cards: [CardOnBoard(card: testCard, hidden: false, descendants: [])])
        
        let game = Game(player1: player1Interactor, player2: player2Interactor, boardFactory: TestBoardFactory(board: testBoard))
        
        player1Interactor.receivedSomePlayerInteraction(interaction: CardTakeAction(requestedCard: testCard))
        XCTAssertEqual(game.player1.cards.count, 1)
        XCTAssertEqual(game.player1.gold, 2)
        XCTAssertTrue(game.board.availableCards.isEmpty)
    }
    
    func testCardOnePlayerAfterAnother() {
        let player1Interactor = TestPlayerInteractor()
        let player2Interactor = TestPlayerInteractor()
        let testCard = Card(name: "1", cost: Resource(wood: 2), providedResource: Resource())
        let testCard2 = Card(name: "2", cost: Resource(stones: 1), providedResource: Resource())
        let cards = [CardOnBoard(card: testCard, hidden: false, descendants: []),
                     CardOnBoard(card: testCard2, hidden: false, descendants: [])]
        let testBoard = Board(cards: cards)
        let game = Game(player1: player1Interactor, player2: player2Interactor, boardFactory: TestBoardFactory(board: testBoard))
        
        player1Interactor.receivedSomePlayerInteraction(interaction: CardTakeAction(requestedCard: testCard))
        XCTAssertEqual(game.player1.cards.count, 1)
        XCTAssertEqual(game.player1.gold, 2)
        XCTAssertEqual(game.board.availableCards.count, 1)
        
        player2Interactor.receivedSomePlayerInteraction(interaction: CardTakeAction(requestedCard: testCard2))
        XCTAssertEqual(game.player2.cards.count, 1)
        XCTAssertEqual(game.player2.gold, 4)
        XCTAssertTrue(game.board.availableCards.isEmpty)
    }
}

class TestBoardFactory: BoardFactory {
    let board: Board
    init(board: Board) {
        self.board = board
    }
    var firstEpohBoard: Board {
        return board
    }
}

class TestCardProvider: CardProvider {
    var firstEpohRandomisedCards: [Card] {
        var cards = [Card]()
        for i in 1...20 {
            cards.append(Card(name: "\(i)"))
        }
        return cards
    }
}

class BoardFactoryTests: XCTestCase {
    func testFirstEpoh() {
        let boardFactory = DefaultBoardFactory(cardProvider: TestCardProvider())
        let firstBoard = boardFactory.firstEpohBoard
        let cardsOnBoard = firstBoard.cards.sorted { (left, right) -> Bool in
            guard let leftName = left?.card.name, let rightName = left?.card.name else { return false }
            return Int(leftName) ?? 0 < Int(rightName) ?? 0
        }
        let firstCardOnBoard = cardsOnBoard[0]
        
        XCTAssertFalse(firstCardOnBoard?.hidden ?? true)
        XCTAssertEqual(firstCardOnBoard?.descendants.count, 2)
        XCTAssertTrue(firstCardOnBoard?.descendants.hasCardNamed("3") ?? false)
        XCTAssertTrue(firstCardOnBoard?.descendants.hasCardNamed("4") ?? false)
        
        let secondCardOnBoard = cardsOnBoard[1]
        XCTAssertFalse(secondCardOnBoard?.hidden ?? true)
        XCTAssertEqual(secondCardOnBoard?.descendants.count, 2)
        XCTAssertTrue(secondCardOnBoard?.descendants.hasCardNamed("4") ?? false)
        XCTAssertTrue(secondCardOnBoard?.descendants.hasCardNamed("5") ?? false)
        
        let fourthCardOnBoard = cardsOnBoard[3]
        XCTAssertTrue(fourthCardOnBoard?.hidden ?? false)
        XCTAssertEqual(fourthCardOnBoard?.descendants.count, 2)
        XCTAssertTrue(fourthCardOnBoard?.descendants.hasCardNamed("7") ?? false)
        XCTAssertTrue(fourthCardOnBoard?.descendants.hasCardNamed("8") ?? false)
        
        let thirteenthCardOnBoard = cardsOnBoard[12]
        XCTAssertTrue(thirteenthCardOnBoard?.hidden ?? false)
        XCTAssertEqual(thirteenthCardOnBoard?.descendants.count, 2)
        XCTAssertTrue(thirteenthCardOnBoard?.descendants.hasCardNamed("18") ?? false)
        XCTAssertTrue(thirteenthCardOnBoard?.descendants.hasCardNamed("19") ?? false)
        
        let eightteenthCardOnBoard = cardsOnBoard[17]
        XCTAssertFalse(eightteenthCardOnBoard?.hidden ?? true)
        XCTAssertEqual(eightteenthCardOnBoard?.descendants.count, 0)
        
    }
}

extension Array where Element:CardOnBoard {
    func hasCardNamed(_ name: String) -> Bool {
        return contains(where: { cardOnBoard -> Bool in
            cardOnBoard.card.name == name
        })
    }
}

class BoardTests: XCTestCase {
    func testNoCards() {
        let board = Board(cards: [])
        let cards = board.availableCards
        XCTAssertTrue(cards.isEmpty)
    }
    
    func testOneCard() {
        let card = Card(name: "Test Card")
        let cardOnBoard = CardOnBoard(card: card, hidden: false, descendants: [])
        let board = Board(cards: [cardOnBoard])
        let availableCards = board.availableCards
        XCTAssertEqual(availableCards.count, 1)
        XCTAssertEqual(availableCards.first?.name, "Test Card")
    }
//
    func testTwoCards() {
        
        let card1 = Card(name: "First Test Card")
        let card2 = Card(name: "Second Test Card")
        let cardOnBoard1 = CardOnBoard(card: card1, hidden: false, descendants: [])
        let cardOnBoard2 = CardOnBoard(card: card2, hidden: false, descendants: [])
        let board = Board(cards: [cardOnBoard1, cardOnBoard2])
        
        let availableCards = board.availableCards
        XCTAssertEqual(availableCards.count, 2)
        XCTAssertEqual(availableCards[0].name, "First Test Card")
        XCTAssertEqual(availableCards[1].name, "Second Test Card")
    }
//
    func testTwoCardsWithDependency() {
        let card1 = Card(name: "First Test Card")
        let card2 = Card(name: "Second Test Card")

        let cardOnBoard2 = CardOnBoard(card: card2, hidden: false, descendants: [])
        let cardOnBoard1 = CardOnBoard(card: card1, hidden: false, descendants: [cardOnBoard2])
        let board = Board(cards: [cardOnBoard1, cardOnBoard2])
        let availableCards = board.availableCards
        XCTAssertEqual(availableCards.count, 1)
        XCTAssertEqual(availableCards.first?.name, "Second Test Card")
    }
    
    func testGetUnavailableCard() {
        let card1 = Card(name: "First Test Card")
        let card2 = Card(name: "Second Test Card")
        
        let cardOnBoard2 = CardOnBoard(card: card2, hidden: false, descendants: [])
        let cardOnBoard1 = CardOnBoard(card: card1, hidden: false, descendants: [cardOnBoard2])
        let board = Board(cards: [cardOnBoard1, cardOnBoard2])
        let claimResult = board.claimCard(card1)
        XCTAssertFalse(claimResult)
    }
    
    func testGetAvailableCard() {
        let card1 = Card(name: "First Test Card")
        let card2 = Card(name: "Second Test Card")
        
        let cardOnBoard2 = CardOnBoard(card: card2, hidden: false, descendants: [])
        let cardOnBoard1 = CardOnBoard(card: card1, hidden: false, descendants: [cardOnBoard2])
        let board = Board(cards: [cardOnBoard1, cardOnBoard2])
        let claimResult = board.claimCard(card2)
        XCTAssertTrue(claimResult)
        let availableCards = board.availableCards
        XCTAssertEqual(availableCards.count, 1)
        XCTAssertEqual(availableCards.first?.name, "First Test Card")
    }
}
