//
//  CommandLineWondersTests.swift
//  CommandLineWondersTests
//
//  Created by Marek Mościchowski on 31/07/2018.
//  Copyright © 2018 Marek Mościchowski. All rights reserved.
//

import XCTest
import Wonders_Mac


class MockOutput: StringOutput {
    var printed: String?
    func print(_ string: String) {
        if let printed = printed {
            self.printed = "\(printed)\n\(string)"
        } else {
            printed = string
        }
    }
}

class TestInteractor: PlayerInteractor {
    func requestAction(game: Wonders_Mac.Game, action: @escaping (Action) -> ()) {
        
    }
}

class TestCardProvider: CardProvider {
    var firstEpohRandomisedCards: [Card] {
        var cards = [Card]()
        for i in 0...20 {
            cards.append(Card(name: "\(i+1)"))
        }
        return cards
    }
}

class TestBoardPresenter: BoardPresenter {
    var availableCards: String = ""
    
    func command(_ command: String, action: @escaping (Action) -> ()) -> Bool {
        passedAction = action
        passedCommand = command
        return false
    }
    
    var presentAvailableCardsCalled = false
    var passedCommand: String?
    var passedAction: ((Action) -> ())?
    func presentAvailableCards() {
        presentAvailableCardsCalled = true
    }
    
    func getCard(index: UInt8) -> Card? {
        return nil
    }
}

class OptionsPresenterTests: XCTestCase {
    func testListCards() {
        let output = MockOutput()
        let game = Wonders_Mac.Game(player1: TestInteractor(), player2: TestInteractor(), cardProvider: TestCardProvider())
        let presenter = OptionsPresenter(game: game, output: output)
        let action = presenter.action(for: "list")
        XCTAssertNil(action)
        XCTAssertEqual("\(welcomeMessage)\n1. 15\n2. 16\n3. 17\n4. 18\n5. 19\n6. 20", output.printed)
    }
    
    func testTakeCard() {
        let output = MockOutput()
        let game = Wonders_Mac.Game(player1: TestInteractor(), player2: TestInteractor(), cardProvider: TestCardProvider())
        let presenter = OptionsPresenter(game: game, output: output)
        let action = presenter.action(for: "take 1")
        let card = game.board.availableCards.first!
        if let cardTakeAction = action as? CardTakeAction {
            XCTAssertEqual(cardTakeAction.requestedCard, card)
        } else {
            XCTFail()
        }
    }
    
    func testNonsenseCommand_1() {
        let output = MockOutput()
        let game = Wonders_Mac.Game(player1: TestInteractor(), player2: TestInteractor(), cardProvider: TestCardProvider())
        let presenter = OptionsPresenter(game: game, output: output)
        let action = presenter.action(for: "1")
        XCTAssertNil(action)
        XCTAssertEqual(output.printed, "\(welcomeMessage)\n\(unknownActionMessage)")
    }
    
    func testSellCard() {
        let output = MockOutput()
        let game = Wonders_Mac.Game(player1: TestInteractor(), player2: TestInteractor(), cardProvider: TestCardProvider())
        let presenter = OptionsPresenter(game: game, output: output)
        let action = presenter.action(for: "sell 2")
        let card = game.board.availableCards[1]
        if let cardSellAction = action as? CardSellAction {
            XCTAssertEqual(cardSellAction.requestedCard, card)
        } else {
            XCTFail()
        }
    }
}

protocol Game {
    var board: Wonders_Mac.Board { get }
}

extension Wonders_Mac.Game: Game {
}

protocol Board {
    var availableCards: [Card] { get }
}

extension Wonders_Mac.Board: Board {
    
}

class TestBoard: Board {
    var availableCards: [Card]
    init(availableCards: [Card]) {
        self.availableCards = availableCards
    }
}

class BoardPresenterTests: XCTestCase {
    func testCoupleCard() {
        let output = MockOutput()
        let card1 = Card(name: "Test Card")
        let card2 = Card(name: "Test Card 2")
        let card3 = Card(name: "Test Card 3")
        let testBoard = TestBoard(availableCards: [card1, card2, card3])
        let presenter: BoardPresenter = DefaultBoardPresenter(board: testBoard, output: output)
        presenter.presentAvailableCards()
        XCTAssertEqual("1. Test Card\n2. Test Card 2\n3. Test Card 3", output.printed)
    }
    
    func testGetCard() {
        let output = MockOutput()
        let card1 = Card(name: "Test Card")
        let testBoard = TestBoard(availableCards: [card1])
        let presenter: BoardPresenter = DefaultBoardPresenter(board: testBoard, output: output)
        let wantedCard = presenter.getCard(index: 0)
        XCTAssertEqual(wantedCard, card1)
    }
    
    func testGetInvalidCard() {
        let output = MockOutput()
        let card1 = Card(name: "Test Card")
        let testBoard = TestBoard(availableCards: [card1])
        let presenter: BoardPresenter = DefaultBoardPresenter(board: testBoard, output: output)
        let wantedCard = presenter.getCard(index: 4)
        XCTAssertNil(wantedCard)
    }
    
    func testAction() {
        let output = MockOutput()
        let card1 = Card(name: "Test Card")
        let testBoard = TestBoard(availableCards: [card1])
        let presenter: BoardPresenter = DefaultBoardPresenter(board: testBoard, output: output)
        let exp = expectation(description: "")
        presenter.command("1") { action in
            XCTAssertTrue(action is CardTakeAction)
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}//
//    func testTwoCards() {
//        let output = MockOutput()
//        let card1 = Card(name: "First Test Card")
//        let card2 = Card(name: "Second Test Card")
//        let cardOnBoard1 = CardOnBoard(card: card1, hidden: false, descendants: [])
//        let cardOnBoard2 = CardOnBoard(card: card2, hidden: false, descendants: [])
//        let board = Board(cards: [cardOnBoard1, cardOnBoard2])
//        let presenter = BoardPresenter(board: board, output: output)
//        presenter.showAvailableCards()
//        XCTAssertEqual("1. First Test Card\n2. Second Test Card", output.printed)
//    }
//
//    func testTwoCardsWithDependency() {
//        let output = MockOutput()
//        let card1 = Card(name: "First Test Card")
//        let card2 = Card(name: "Second Test Card")
//
//        let cardOnBoard2 = CardOnBoard(card: card2, hidden: false, descendants: [])
//        let cardOnBoard1 = CardOnBoard(card: card1, hidden: false, descendants: [cardOnBoard2])
//        let board = Board(cards: [cardOnBoard1, cardOnBoard2])
//        let presenter = BoardPresenter(board: board, output: output)
//        presenter.showAvailableCards()
//        XCTAssertEqual("1. First Test Card", output.printed)
//    }
//}
