import Quick
import Nimble
@testable import Cogito

class AppReducerSpec: QuickSpec {
    override func spec() {
        it("returns initial state when reset") {
            let identity = Identity.example
            let state = appState(
                keyStore: KeyStoreState(keyStore: KeyStore(name: "test", scryptN: 0, scryptP: 0)),
                geth: GethState(peersCount: 1, syncProgress: nil),
                createIdentity: CreateIdentityState(description: "test", pending: true, newAccount: nil, error: "test"),
                diamond: DiamondState(facets: [identity]),
                telepath: TelepathState(channels: [TelepathChannel.example: identity.identifier], connectionError: nil)
            )
            let action = ResetAppState()
            let nextState = appReducer(action: action, state: state)
            expect(nextState) == initialAppState
        }
    }
}
