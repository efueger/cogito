//  Copyright © 2018 Koninklijke Philips Nederland N.V. All rights reserved.

import Quick
import Nimble

class EncryptionServiceSpec: QuickSpec {
    override func spec() {
        var service: EncryptionService!
        var store: RecordingStore!
        var channel: TelepathChannel!
        var identity: Identity!
        var keyPairCreator: KeyPairCreatorSpy!
        var publicKeyLoader: PublicKeyLoaderSpy!

        beforeEach {
            store = RecordingStore()
            service = EncryptionService(store: store)
            channel = TelepathChannelSpy()
            identity = Identity(description: "example", address: Address.testAddress)
            keyPairCreator = KeyPairCreatorSpy()
            publicKeyLoader = PublicKeyLoaderSpy()
            service.publicKeyLoader = publicKeyLoader
            service.keyPairCreator = keyPairCreator
        }

        context("when a create encryption key pair request comes in") {
            let request = JsonRpcRequest(
                id: JsonRpcId(1),
                method: "createEncryptionKeyPair",
                params: JsonRpcParams()
            )

            beforeEach {
                store.state = appState(
                    telepath: TelepathState(channels: [channel: identity])
                )
                service.onRequest(request, on: channel)
            }

            it("creates an new key pair in keychain") {
                expect(keyPairCreator.createWasCalled).to(beTrue())
            }

            it("generates unique ids") {
                service.onRequest(request, on: channel)
                let tag1 = keyPairCreator.latestTag
                service.onRequest(request, on: channel)
                let tag2 = keyPairCreator.latestTag
                expect(tag1) != tag2
            }

            it("dispatches StoreEncryptionKeyPair action") {
                let action = store.firstAction(ofType: DiamondActions.StoreEncryptionKeyPair.self)
                expect(action).toNot(beNil())
            }

            it("uses the identity that is associated with the channel") {
                let action = store.firstAction(ofType: DiamondActions.StoreEncryptionKeyPair.self)
                expect(action?.identity) == store.state.telepath.channels[channel]
            }

            it("sends response on Telepath channel") {
                let sendPendingAction = store.firstAction(ofType: TelepathActions.SendPending.self)
                expect(sendPendingAction?.message).to(contain(keyPairCreator.latestTag!))
            }
        }

        context("when a public key is requested") {
            let tag = "1234-5678"
            let publicKey = "some public key".data(using: .utf8)!

            context("when the public key is available") {
                beforeEach {
                    identity.encryptionKeyPairs = [tag]
                    store.state = appState(
                        telepath: TelepathState(channels: [channel: identity])
                    )
                    publicKeyLoader.publicKeyToReturn = publicKey
                }

                it("loads the public key with the correct tag") {
                    let request = JsonRpcRequest(
                        id: JsonRpcId(1),
                        method: "getEncryptionPublicKey",
                        params: JsonRpcParams(["tag": tag])
                    )
                    service.onRequest(request, on: channel)
                    expect(publicKeyLoader.latestTag).to(equal(tag))
                }

                it("sends response on Telepath channel") {
                    let request = JsonRpcRequest(
                        id: JsonRpcId(1),
                        method: "getEncryptionPublicKey",
                        params: JsonRpcParams(["tag": tag])
                    )
                    service.onRequest(request, on: channel)
                    let sendPendingAction = store.firstAction(ofType: TelepathActions.SendPending.self)
                    expect(sendPendingAction?.message).to(contain(publicKey.hexEncodedString()))
                }

                it("sends an error when tag is missing in request") {
                    let request = JsonRpcRequest(
                        id: JsonRpcId(1),
                        method: "getEncryptionPublicKey",
                        params: JsonRpcParams()
                    )
                    service.onRequest(request, on: channel)
                    let sendPendingAction = store.firstAction(ofType: TelepathActions.SendPending.self)
                    expect(sendPendingAction?.message).to(contain("\"code\" : \(EncryptionError.tagMissing.rawValue)"))
                }
            }

            context("when the public key is not available") {
                beforeEach {
                    identity.encryptionKeyPairs = [tag]
                    store.state = appState(
                        telepath: TelepathState(channels: [channel: identity])
                    )
                }

                it("returns an error") {
                    let request = JsonRpcRequest(
                        id: JsonRpcId(1),
                        method: "getEncryptionPublicKey",
                        params: JsonRpcParams(["tag": tag])
                    )
                    service.onRequest(request, on: channel)
                    let sendPendingAction = store.firstAction(ofType: TelepathActions.SendPending.self)
                    expect(sendPendingAction?.message).to(contain("\"code\" : \(EncryptionError.keyNotFound.rawValue)"))
                }
            }

            context("when the identity does not contain the key pair") {
                beforeEach {
                    identity.encryptionKeyPairs = []
                    store.state = appState(
                        telepath: TelepathState(channels: [channel: identity])
                    )
                    publicKeyLoader.publicKeyToReturn = publicKey
                }

                it("returns an error") {
                    let request = JsonRpcRequest(
                        id: JsonRpcId(1),
                        method: "getEncryptionPublicKey",
                        params: JsonRpcParams(["tag": tag])
                    )
                    service.onRequest(request, on: channel)
                    let sendPendingAction = store.firstAction(ofType: TelepathActions.SendPending.self)
                    expect(sendPendingAction?.message).to(contain("\"code\" : \(EncryptionError.keyNotFound.rawValue)"))
                }
            }
        }

        context("when another request comes in") {
            it("does not dispatch anything") {
                let actionCountBefore = store.actions.count
                let request = JsonRpcRequest(
                    id: JsonRpcId(1),
                    method: "some other request",
                    params: JsonRpcParams()
                )
                service.onRequest(request, on: channel)
                expect(store.actions.count) == actionCountBefore
            }
        }
    }
}
