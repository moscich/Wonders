import Foundation

struct CardStore: Decodable {
    let epohs: [Epoh]
}

struct Epoh: Decodable {
    let cards: [Card]
}

class RandomCardProvider: CardProvider {
    let store: CardStore
    let count: Int
    let randomSequence: (Int) -> [Int]
    convenience init(count: Int, file: String = "cards.json") {
        self.init(count: count, file: file) { count -> [Int] in
            Array(0...count-1).shuffled()
        }
    }
    
    init(count: Int, file: String, randomSequence: @escaping (Int) -> [Int]) {
        self.count = count
        self.randomSequence = randomSequence
        let url = Bundle(for: type(of: self)).url(forResource: file, withExtension: nil)
        let data = try? Data(contentsOf: url!)
        store = try! JSONDecoder().decode(CardStore.self, from: data!)
    }
    
    var firstEpohRandomisedCards: [Card] {
        return randomSequence(count).map { index -> Card in
            (store.epohs.first?.cards[index])!
        }
    }
}
