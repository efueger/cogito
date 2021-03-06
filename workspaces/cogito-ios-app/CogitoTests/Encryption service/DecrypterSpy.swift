import Foundation
@testable import Cogito

class DecrypterSpy: DecrypterType {
    var plainTextToReturn: Data?

    var latestKeyTag: String?
    var latestCipherText: Data?

    func decrypt(keyTag: String, cipherText: Data) -> Data? {
        latestKeyTag = keyTag
        latestCipherText = cipherText
        return plainTextToReturn
    }
}
