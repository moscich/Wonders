import Foundation

class Shop {
    func resourceCost(_ resource: Resource, oponentResource: Resource) -> Int {
        return resource.wood * (2 + oponentResource.wood) +
            resource.clay * (2 + oponentResource.clay) +
            resource.papyrus * (2 + oponentResource.papyrus) +
            resource.glass * (2 + oponentResource.glass) +
            resource.stones * (2 + oponentResource.stones)
    }
}

public class Card: Equatable {
    public static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs === rhs
    }
    
    public let cost: Resource
    public var providedResource = Resource()
    public var name: String
    public init(name: String, cost: Resource = Resource(), providedResource: Resource = Resource()) {
        self.cost = cost
        self.providedResource = providedResource
        self.name = name
    }
}

public struct Resource: Equatable {
    let wood: Int
    let stones: Int
    let clay: Int
    let glass: Int
    let papyrus: Int
    let gold: Int
    
    public init(wood: Int = 0,
         stones: Int = 0,
         clay: Int = 0,
         glass: Int = 0,
         papyrus: Int = 0,
         gold: Int = 0
        ) {
        self.wood = wood
        self.stones = stones
        self.clay = clay
        self.glass = glass
        self.papyrus = papyrus
        self.gold = gold
    }
    
    var withoutNegative: Resource {
        return Resource(wood: wood > 0 ? wood : 0,
                        stones: stones > 0 ? stones : 0,
                        clay: clay > 0 ? clay : 0,
                        glass: glass > 0 ? glass : 0,
                        papyrus: papyrus > 0 ? papyrus : 0,
                        gold: gold > 0 ? gold : 0)
    }
}

func +(left: Resource, rigth: Resource) -> Resource {
    return Resource(wood: left.wood + rigth.wood,
                    stones: left.stones + rigth.stones,
                    clay: left.clay + rigth.clay,
                    glass: left.glass + rigth.glass,
                    papyrus: left.papyrus + rigth.papyrus,
                    gold: left.gold + rigth.gold)
}

func -(left: Resource, rigth: Resource) -> Resource {
    return Resource(wood: left.wood - rigth.wood,
                    stones: left.stones - rigth.stones,
                    clay: left.clay - rigth.clay,
                    glass: left.glass - rigth.glass,
                    papyrus: left.papyrus - rigth.papyrus,
                    gold: left.gold - rigth.gold)
}

class Player {
    var cards: [Card] = []
    var gold: Int = 6
}

class ResourceCalculator {
    func concreteResources(in cards: [Card]) -> Resource {
        return cards.reduce(Resource(), { (result: Resource, card) -> Resource in
            result + card.providedResource
        })
    }
    
    func requiredResources(for card: Card, player: Player) -> Resource {
        let resources = concreteResources(in: player.cards)
        return (card.cost - resources).withoutNegative
    }
    
    // draft
    //    func possibleResources(in cards: [Card]) -> Resource {
    //
    //    }
}

public protocol Action {
    
}

public protocol PlayerInteractor {
    func requestAction(game: Game, action: @escaping (Action) -> ())
}

class TestPlayerInteractor: PlayerInteractor {
    var wasAskedForAction = false
    var action: ((Action) -> ())?
    
    func requestAction(game: Game, action: @escaping (Action) -> ()) {
        wasAskedForAction = true
        self.action = action
    }
    
    func receivedSomePlayerInteraction(interaction: Action) {
        action?(interaction)
    }
}

class RandomCardProvider: CardProvider {
    var firstEpohRandomisedCards: [Card] {
        return []
    }
}

public class Game {
    let board: Board
    let player1Interactor: PlayerInteractor
    let player2Interactor: PlayerInteractor
    var player1 = Player()
    let player2 = Player()
    var currentPlayer = 0
    let resourceCalculator = ResourceCalculator()
    let shop = Shop()
    let boardFactory: BoardFactory
    
    init(player1: PlayerInteractor, player2: PlayerInteractor, boardFactory: BoardFactory) {
        self.player1Interactor = player1
        self.player2Interactor = player2
        self.boardFactory = boardFactory
        self.board = boardFactory.firstEpohBoard
        player1.requestAction(game: self, action: actionHey())
    }
    
    convenience public init(player1: PlayerInteractor, player2: PlayerInteractor) {
        self.init(player1: player1, player2: player2, boardFactory: DefaultBoardFactory(cardProvider: RandomCardProvider()))
    }
    
    private func actionHey() -> ((Action) -> ()) {
        return { [weak self] action in
            guard let `self` = self else { return }
            if self.currentPlayer == 0 {
                if let cardAction = action as? CardTakeAction {
                    let card = cardAction.requestedCard
                    if self.board.claimCard(cardAction.requestedCard) {
                        let requiredResources = self.resourceCalculator.requiredResources(for: card, player: self.player1)
                        let player2Resources = self.resourceCalculator.concreteResources(in: self.player2.cards)
                        let requiredGold = self.shop.resourceCost(requiredResources, oponentResource: player2Resources)
                        self.player1.cards.append(card)
                        self.player1.gold -= requiredGold
                    }
                }
                self.currentPlayer = 1
                self.player2Interactor.requestAction(game: self, action: self.actionHey())
            } else {
                self.currentPlayer = 0
                self.player1Interactor.requestAction(game: self, action: self.actionHey())
                
            }
        }
    }
    
    func getCard(at: Int) -> Card {
        return Card(name: "", cost: Resource(), providedResource: Resource())
    }
}

public struct CardTakeAction: Action {
    let requestedCard: Card
    public init(requestedCard: Card) {
        self.requestedCard = requestedCard
    }
}

struct TestAction: Action {
    
}

class Board {
    var cards: [CardOnBoard?]
    init(cards: [CardOnBoard?]) {
        self.cards = cards
    }
    
    func getCard(at index: Int) -> Card {
        return Card(name: "", cost: Resource(), providedResource: Resource())
    }
    
    func claimCard(_ card: Card) -> Bool {
        guard (availableCards.contains { availableCard -> Bool in
            availableCard === card
        }) else { return false }
        for cardOnBoard in cards {
            cardOnBoard?.descendants.removeAll(where: { descendant -> Bool in
                descendant.card === card
            })
        }
        cards.removeAll { cardOnBoard -> Bool in
            cardOnBoard?.card === card
        }

        return true
    }
    
    var availableCards: [Card] {
        return cards.filter({ cardOnBoard -> Bool in
            cardOnBoard != nil
        }).filter({ cardOnBoard -> Bool in
            cardOnBoard!.descendants.isEmpty
        }).map({ cardOnBoard -> Card in
            return cardOnBoard!.card
        })
    }
}

protocol CardProvider {
    var firstEpohRandomisedCards: [Card] { get }
}

protocol BoardFactory {
    var firstEpohBoard: Board { get }
}

class DefaultBoardFactory: BoardFactory {
    let cardProvider: CardProvider
    init(cardProvider: CardProvider) {
        self.cardProvider = cardProvider
    }
    var firstEpohBoard: Board {
        // TODO
        var cards = [CardOnBoard]()
        for _ in 0...19 {
            cards.append(CardOnBoard(hidden: true, descendants: []))
        }
        return Board(cards: cards)
    }
}

public class CardOnBoard {
    public var hidden: Bool
    public var card: Card
    public var descendants: [CardOnBoard]
    
    public init(card: Card = Card(name: ""), hidden: Bool, descendants: [CardOnBoard]) {
        self.hidden = hidden
        self.descendants = descendants
        self.card = card
    }
}
