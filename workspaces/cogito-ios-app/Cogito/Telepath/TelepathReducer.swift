import ReSwift

func telepathReducer(_ action: Action, _ state: TelepathState?) -> TelepathState {
    var nextState = state ?? initialTelepathState
    switch action {
    case let connected as TelepathActions.ConnectFulfilled:
        nextState.channels = nextState.channels.filter({ (_, value) -> Bool in
            return value != connected.identity.identifier
        })
        nextState.channels[connected.channel] = connected.identity.identifier
    case let connectFailure as TelepathActions.ConnectRejected:
        nextState.connectionError = connectFailure.error.localizedDescription
    case let received as TelepathActions.ReceiveFulfilled:
        let message = TelepathMessage(message: received.message, channel: received.channel)
        nextState.receivedMessages.append(message)
    case let receiveFailure as TelepathActions.ReceiveRejected:
        nextState.receiveError = receiveFailure.error.localizedDescription
    case is TelepathActions.ReceivedMessageHandled:
        nextState.receivedMessages.remove(at: 0)
    default:
        break
    }
    return nextState
}
