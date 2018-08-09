import XCTest
@testable import Wonders

class ShopTests: XCTestCase {
    var shop: Shop!
    override func setUp() {
        shop = Shop()
    }
    
    func testOneWoodCost_noCards() {
        let cost = shop.resourceCost(Resource(wood: 1), oponentResource: Resource())
        XCTAssertEqual(cost, 2)
    }
    
    func testOneWoodOneClayCost_noCards() {
        let cost = shop.resourceCost(Resource(wood: 1, clay: 1), oponentResource: Resource())
        XCTAssertEqual(cost, 4)
    }
    
    func testOneWood_OpponentHas1Wood() {
        let cost = shop.resourceCost(Resource(wood: 1), oponentResource: Resource(wood: 1))
        XCTAssertEqual(cost, 3)
    }
    
    func testOneOfEach_OpponentHas1Wood2stones3papyrus4clay5glass() {
        let cost = shop.resourceCost(Resource(wood: 1, stones: 1, clay: 1, glass: 1, papyrus: 1), oponentResource: Resource(wood: 1, stones: 2, clay: 3, glass: 4, papyrus: 5))
        XCTAssertEqual(cost, 25)
    }
    
    func testWoodCost1WhenHasWerehouse() {
        let player = Player()
        let werehouse = TestCard(feature: .woodWerehouse)
        player.cards.append(werehouse)
        let cost = shop.resourceCost(Resource(wood: 2), player: player, oponentResource: Resource(wood: 5))
        XCTAssertEqual(cost, 2)
    }
    
    func testStoneCost1WhenHasWerehouse() {
        let player = Player()
        let werehouse = TestCard(feature: .stoneWerehouse)
        player.cards.append(werehouse)
        let cost = shop.resourceCost(Resource(stones: 2), player: player, oponentResource: Resource(stones: 5))
        XCTAssertEqual(cost, 2)
    }
    
    func testClayCost1WhenHasWerehouse() {
        let player = Player()
        let werehouse = TestCard(feature: .clayWerehouse)
        player.cards.append(werehouse)
        let cost = shop.resourceCost(Resource(clay: 2), player: player, oponentResource: Resource(clay: 5))
        XCTAssertEqual(cost, 2)
    }
    
    func testGold() {
        let cost = shop.resourceCost(Resource(gold: 5), oponentResource: Resource())
        XCTAssertEqual(cost, 5)
    }
}

class TestCard: Card {
    var features: [CardFeature] = []
    var providedResource: Resource
    var cost: Resource
    var name: String
    init(name: String = "", cost: Resource = Resource(), providedResource: Resource = Resource()) {
        features.append(CardFeature.provideResource(resource: providedResource))
        self.providedResource = providedResource
        self.cost = cost
        self.name = name
    }
    
    convenience init(feature: CardFeature) {
        self.init(name: "", cost: Resource(), providedResource: Resource())
        features.append(feature)
    }
    
    convenience init(providedResource: Resource) {
        self.init(name: "", cost: Resource(), providedResource: providedResource)
    }
    
    convenience init() {
        self.init(name: "", cost: Resource(), providedResource: Resource())
    }
}

class ResourceCalculatorTests: XCTestCase {
    func testResourceSummary() {
        let calculator = ResourceCalculator()
        
        let woodCard = TestCard(providedResource: Resource(wood: 2))
        let clayCard = TestCard(providedResource: Resource(clay: 1))
        let resources = calculator.concreteResources(in: [woodCard, clayCard])
        XCTAssertEqual(resources, Resource(wood: 2, clay: 1))
    }
    
    func testRequiredResources() {
        let calculator = ResourceCalculator()
        let card = TestCard(cost: Resource(wood: 1, stones: 3, clay: 2))
        let player1 = Player()
        player1.cards = [TestCard(providedResource: Resource(wood: 3, stones: 1))]
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
    
//    func testPlayersTakeActionsOneAfterAnother() {
//        let player1Interactor = TestPlayerInteractor()
//        let player2Interactor = TestPlayerInteractor()
//        let game = Game(player1: player1Interactor, player2: player2Interactor)
//        XCTAssertTrue(player1Interactor.wasAskedForAction)
//        XCTAssertFalse(player2Interactor.wasAskedForAction)
//        player1Interactor.receivedSomePlayerInteraction(interaction: TestAction())
//        XCTAssertTrue(player2Interactor.wasAskedForAction)
//
//        player1Interactor.wasAskedForAction = false
//        player2Interactor.wasAskedForAction = false
//
//        player2Interactor.receivedSomePlayerInteraction(interaction: TestAction())
//
//        XCTAssertTrue(player1Interactor.wasAskedForAction)
//        print(game)
//    }
//
    func testCardTakeAction() {
        let player1Interactor = TestPlayerInteractor()
        let player2Interactor = TestPlayerInteractor()
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
        let player1Interactor = TestPlayerInteractor()
        let player2Interactor = TestPlayerInteractor()
        let testCard = TestCard(cost: Resource(wood: 2))
        let testBoard = Board(cards: [CardOnBoard(card: testCard, hidden: false, descendants: [])])
        
        let game = Game(player1: player1Interactor, player2: player2Interactor, boardFactory: TestBoardFactory(board: testBoard))
        
        player1Interactor.receivedSomePlayerInteraction(interaction: .takeCard(testCard))
        XCTAssertEqual(game.player1.cards.count, 1)
        XCTAssertEqual(game.player1.gold, 2)
        XCTAssertTrue(game.board.availableCards.isEmpty)
    }
    
    func testCardOnePlayerAfterAnother() {
        let player1Interactor = TestPlayerInteractor()
        let player2Interactor = TestPlayerInteractor()
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
        let player1Interactor = TestPlayerInteractor()
        let player2Interactor = TestPlayerInteractor()
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
        let player1Interactor = TestPlayerInteractor()
        let player2Interactor = TestPlayerInteractor()
        let testCard = TestCard(cost: Resource(wood: 4))
        let testBoard = Board(cards: [CardOnBoard(card: testCard, hidden: false, descendants: [])])
        
        let game = Game(player1: player1Interactor, player2: player2Interactor, boardFactory: TestBoardFactory(board: testBoard))
        
        player1Interactor.receivedSomePlayerInteraction(interaction: .sellCard(testCard))
        XCTAssertEqual(game.player1.cards.count, 0)
        XCTAssertEqual(game.player1.gold, 8)
        XCTAssertTrue(game.board.availableCards.isEmpty)
        XCTAssertTrue(player2Interactor.wasAskedForAction)
    }
    
//    func testBuildWonderAction() {
//        let player1Interactor = TestPlayerInteractor()
//        let player2Interactor = TestPlayerInteractor()
//        let testBoard = Board(cards: [CardOnBoard(name: "Test")])
//        let game = Game(player1: player1Interactor, player2: player2Interactor, boardFactory: TestBoardFactory(board: testBoard))
////        player1Interactor.receivedSomePlayerInteraction(interaction: CardSellAction(requestedCard: testCard))
//    }
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
            cards.append(TestCard(name: "\(i)"))
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

extension CardOnBoard {
    convenience init(name: String, descendants: [CardOnBoard] = []) {
        let card = TestCard(name: name)
        self.init(card: card, hidden: false, descendants: descendants)
    }
}

class BoardTests: XCTestCase {
    func testNoCards() {
        let board = Board(cards: [])
        let cards = board.availableCards
        XCTAssertTrue(cards.isEmpty)
    }
    
    func testOneCard() {
        let board = Board(cards: [CardOnBoard(name: "Test Card")])
        XCTAssertEqual(board.availableCards.count, 1)
        XCTAssertEqual(board.availableCards.first?.name, "Test Card")
    }
    
    func testTwoCards() {
        let card1 = CardOnBoard(name: "First Test Card")
        let card2 = CardOnBoard(name: "Second Test Card")
        let board = Board(cards: [card1, card2])
        
        let availableCards = board.availableCards
        XCTAssertEqual(availableCards.count, 2)
        XCTAssertEqual(availableCards[0].name, "First Test Card")
        XCTAssertEqual(availableCards[1].name, "Second Test Card")
    }
    
    func testTwoCardsWithDependency() {
        let card2 = CardOnBoard(name: "Second Test Card")
        let card1 = CardOnBoard(name: "First Test Card", descendants: [card2])
        let board = Board(cards: [card1, card2])
        let availableCards = board.availableCards
        XCTAssertEqual(availableCards.count, 1)
        XCTAssertEqual(availableCards.first?.name, "Second Test Card")
    }
    
    func testGetUnavailableCard() {
        let card1 = TestCard(name: "First Test Card")
        let card2 = TestCard(name: "Second Test Card")
        
        let cardOnBoard2 = CardOnBoard(card: card2, hidden: false, descendants: [])
        let cardOnBoard1 = CardOnBoard(card: card1, hidden: false, descendants: [cardOnBoard2])
        let board = Board(cards: [cardOnBoard1, cardOnBoard2])
        let claimResult = board.claimCard(card1)
        XCTAssertFalse(claimResult)
    }
    
    func testGetAvailableCard() {
        let card1 = TestCard(name: "First Test Card")
        let card2 = TestCard(name: "Second Test Card")
        
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

class RandomCardProviderTests: XCTestCase {
    func testOneCardProvider() {
        if let url = Bundle(for: type(of: self)).url(forResource: "one_card.json", withExtension: nil) {
            let cardProvider = RandomCardProvider(count: 1, file: url)
            if let card = cardProvider.firstEpohRandomisedCards.first {
                XCTAssertEqual(card.name, "Test")
                XCTAssertEqual(card.cost, Resource(gold: 1))
                XCTAssertEqual(card.providedResource, Resource(wood: 1, stones: 2, clay: 3, glass: 4, papyrus: 5, gold: 0))
            } else {
                XCTFail()
            }
        } else {
            XCTFail()
        }
    }
    
    func testOneCardLimited() {
        if let url = Bundle(for: type(of: self)).url(forResource: "two_cards", withExtension: "json") {
            let cardProvider = RandomCardProvider(count: 1, file: url)
            XCTAssertEqual(cardProvider.firstEpohRandomisedCards.count, 1)
            if let card = cardProvider.firstEpohRandomisedCards.first {
                XCTAssertEqual(card.name, "Test")
            } else {
                XCTFail()
            }
            
        } else {
            XCTFail()
        }
        
    }
    
    func testTwoCardsShuffled() {
        if let url = Bundle(for: type(of: self)).url(forResource: "two_cards", withExtension: "json") {
            let cardProvider = RandomCardProvider(count: 2, file: url) { _ in [1, 0] }
            XCTAssertEqual(cardProvider.firstEpohRandomisedCards.count, 2)
            
            XCTAssertEqual(cardProvider.firstEpohRandomisedCards[0].name, "Test2")
            XCTAssertEqual(cardProvider.firstEpohRandomisedCards[1].name, "Test")
        }
    }
    
    func testProductionJson() {
        if let url = Bundle(for: RandomCardProvider.self).url(forResource: "cards", withExtension: "json") {
            let cardProvider = RandomCardProvider(count: 23, file: url)
            XCTAssertEqual(cardProvider.firstEpohRandomisedCards.count, 23)
        } else {
            XCTFail()
        }
    }
}

