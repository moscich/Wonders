import Foundation

struct CardStore: Decodable {
    let epohs: [Epoh]
}

struct Epoh: Decodable {
    let cards: [DefaultCard]
}

class RandomCardProvider: CardProvider {
    let store: CardStore
    let count: Int
    let randomSequence: (Int) -> [Int]
    convenience init(count: Int = 20, file: URL) {
        self.init(count: count, file: file) { count -> [Int] in
            Array(0...count-1).shuffled()
        }
    }
        
    init(count: Int, file: URL, randomSequence: @escaping (Int) -> [Int]) {
        self.count = count
        self.randomSequence = randomSequence
        let data = try? Data(contentsOf: file)
        store = try! JSONDecoder().decode(CardStore.self, from: data!)
    }
    
    var firstEpohRandomisedCards: [Card] {
        return randomSequence(count).map { index -> Card in
            (store.epohs.first?.cards[index])!
        }
    }
}

// old swift compatibility
extension Array where Element == Int {
    func shuffled() -> [Int] {
        var result = self
        for _ in 0...100 {
            let first = Int(arc4random_uniform(UInt32(result.count)))
            let second = Int(arc4random_uniform(UInt32(result.count)))
            let elem = result[first]
            result[first] = result[second]
            result[second] = elem
        }
        return result
    }
}
