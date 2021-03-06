import ReSwift
import ReSwiftThunk
@testable import Cogito

class RecordingStore: Store<AppState> {
    var actions = [Action]()

    convenience init(state: AppState = initialAppState) {
        let reducer: Reducer<AppState> = { _, currentState in
            return currentState ?? state
        }
        self.init(reducer: reducer, state: nil, middleware: [ThunkMiddleware()])
    }

    override func dispatch(_ action: Action) {
        actions.append(action)
        super.dispatch(action)
    }
}

extension RecordingStore {
    func firstAction <T> (ofType: T.Type) -> T? {
        return actions.compactMap { $0 as? T }.first
    }
}

struct TracerAction: Action {}
