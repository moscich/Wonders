import Foundation

public protocol Card: class {
    var features: [CardFeature] { get }
    var cost: Resource { get }
    var name: String { get }
}

public enum CardFeature: Decodable, Equatable {
    enum CodingKeys: String, CodingKey {
        case wood
        case stones
        case clay
        case glass
        case papyrus
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let wood = (try? values.decode(Int.self, forKey: .wood)) ?? 0
        let stones = (try? values.decode(Int.self, forKey: .stones)) ?? 0
        let clay = (try? values.decode(Int.self, forKey: .clay)) ?? 0
        let glass = (try? values.decode(Int.self, forKey: .glass)) ?? 0
        let papyrus = (try? values.decode(Int.self, forKey: .papyrus)) ?? 0
        
        self = CardFeature.provideResource(resource: Resource(wood: wood, stones: stones, clay: clay, glass: glass, papyrus: papyrus))
    }
    
    case provideResource(resource: Resource)
    case woodWerehouse
    case stoneWerehouse
    case clayWerehouse
    case gainGold(gold: Int)
    case removeGold(gold: Int)
    case takeExtraTurn
    case addMilitary(shield: Int)
    case removeCard
}

public class DefaultCard: Card, Decodable {
    
    public var name: String
    public let features: [CardFeature]
    public let cost: Resource
    public var providedResource: Resource {
        if let feature = features.first {
            if case let CardFeature.provideResource(resource: res) = feature {
                return res
            }
        }
        return Resource()
    }
    
    enum CodingKeys: String, CodingKey {
        case cost
        case name
        case provide
        case features
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cost = (try? values.decode(Resource.self, forKey: .cost)) ?? Resource()
        name = try values.decode(String.self, forKey: .name)
        features = (try? values.decode([CardFeature].self, forKey: .features)) ?? []
    }
}

public struct Resource: Equatable, Decodable {
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
    
    enum CodingKeys: String, CodingKey {
        case wood
        case stones
        case clay
        case glass
        case papyrus
        case gold
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        wood = (try? values.decode(Int.self, forKey: .wood)) ?? 0
        stones = (try? values.decode(Int.self, forKey: .stones)) ?? 0
        clay = (try? values.decode(Int.self, forKey: .clay)) ?? 0
        glass = (try? values.decode(Int.self, forKey: .glass)) ?? 0
        papyrus = (try? values.decode(Int.self, forKey: .papyrus)) ?? 0
        gold = (try? values.decode(Int.self, forKey: .gold)) ?? 0
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

public class Player {
    public var cards: [Card] = []
    public var gold: Int = 6
    public var wonders: [Wonder] = [Wonder(), Wonder(), Wonder(), Wonder()]
}

public class Wonder {
    let cost: Resource
    var built = false
    let features: [CardFeature]
    init(features: [CardFeature] = [], cost: Resource = Resource()) {
        self.features = features
        self.cost = cost
    }
}

public enum Action {
    case sellCard(Card)
    case takeCard(Card)
    case buildWonder(Wonder, Card)
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

public struct CardTakeAction {
    public let requestedCard: Card
    public init(requestedCard: Card) {
        self.requestedCard = requestedCard
    }
}

public struct CardSellAction {
    public let requestedCard: Card
    public init(requestedCard: Card) {
        self.requestedCard = requestedCard
    }
}

public class Board {
    var cards: [CardOnBoard?]
    init(cards: [CardOnBoard?]) {
        self.cards = cards
    }
    
    public var availableCards: [Card] {
        return cards.filter({ cardOnBoard -> Bool in
            cardOnBoard != nil
        }).filter({ cardOnBoard -> Bool in
            cardOnBoard!.descendants.isEmpty
        }).map({ cardOnBoard -> Card in
            return cardOnBoard!.card
        })
    }
    
    func claimCard(_ card: Card) -> Bool {
        guard (availableCards.contains { availableCard -> Bool in
            availableCard === card
        }) else { return false }
        for cardOnBoard in cards {
            guard let cardOnBoard = cardOnBoard else { continue }
            cardOnBoard.descendants = cardOnBoard.descendants.filter({ descendant -> Bool in
                descendant.card !== card
            })
        }
        cards.remove(card: card)
        return true
    }
}

extension Array where Element == CardOnBoard? {
    mutating func remove(card: Card) {
        guard let index = (index { (cardOnBoard: CardOnBoard?) -> Bool in
            card === cardOnBoard?.card
        }) else { return }
        remove(at: index)
    }
}

public protocol CardProvider {
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
        let cards = cardProvider.firstEpohRandomisedCards
        
        var rows = [[CardOnBoard]]()
        
        for row in 0...4 {
            let rowCards = cards[startingCardIndex(for: row)...startingCardIndex(for: row) + 1 + row].map { card -> CardOnBoard in
                CardOnBoard(card: card, hidden: row % 2 == 1, descendants: [])
            }
            rows.append(rowCards)
        }
        
        var cardsOnBoard = [CardOnBoard]()
        for (index, row) in rows.enumerated() {
            cardsOnBoard.append(contentsOf: row)
            guard let previousRow = index > 0 ? rows[index - 1] : nil else { continue }
            for (index, card) in previousRow.enumerated() {
                card.descendants = [row[index], row[index + 1]]
            }
        }
      
        return Board(cards: cardsOnBoard)
    }
    
    private func startingCardIndex(for row: Int) -> Int {
        if row == 0 {
            return 0
        } else if row == 1 {
            return 2
        } else {
            return startingCardIndex(for:row - 1) + row + 1
        }
    }
}

public class CardOnBoard {
    public var hidden: Bool
    public var card: Card
    public var descendants: [CardOnBoard]
    
    public init(card: Card, hidden: Bool, descendants: [CardOnBoard]) {
        self.hidden = hidden
        self.descendants = descendants
        self.card = card
    }
}
