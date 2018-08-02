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

class BoardPresenterTests: XCTestCase {
    func testNoCards() {
        let output = MockOutput()
        let board = Board(cards: [])
        let presenter = BoardPresenter(board: board, output: output)
        presenter.showAvailableCards()
        XCTAssertEqual("No Cards", output.printed)
    }
    
    func testOneCard() {
        let output = MockOutput()
        let card = Card(name: "Test Card")
        let cardOnBoard = CardOnBoard(card: card, hidden: false, descendants: [])
        let board = Board(cards: [cardOnBoard])
        let presenter = BoardPresenter(board: board, output: output)
        presenter.showAvailableCards()
        XCTAssertEqual("1. Test Card", output.printed)
    }
    
    func testTwoCards() {
        let output = MockOutput()
        let card1 = Card(name: "First Test Card")
        let card2 = Card(name: "Second Test Card")
        let cardOnBoard1 = CardOnBoard(card: card1, hidden: false, descendants: [])
        let cardOnBoard2 = CardOnBoard(card: card2, hidden: false, descendants: [])
        let board = Board(cards: [cardOnBoard1, cardOnBoard2])
        let presenter = BoardPresenter(board: board, output: output)
        presenter.showAvailableCards()
        XCTAssertEqual("1. First Test Card\n2. Second Test Card", output.printed)
    }
    
    func testTwoCardsWithDependency() {
        let output = MockOutput()
        let card1 = Card(name: "First Test Card")
        let card2 = Card(name: "Second Test Card")
        
        let cardOnBoard2 = CardOnBoard(card: card2, hidden: false, descendants: [])
        let cardOnBoard1 = CardOnBoard(card: card1, hidden: false, descendants: [cardOnBoard2])
        let board = Board(cards: [cardOnBoard1, cardOnBoard2])
        let presenter = BoardPresenter(board: board, output: output)
        presenter.showAvailableCards()
        XCTAssertEqual("1. First Test Card", output.printed)
    }
}
