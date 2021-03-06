public protocol QueuingService {
    func send(queueId: QueueID, message: Data, completion: @escaping (Error?) -> Void)
    func receive(queueId: QueueID, completion: @escaping (Data?, Error?) -> Void)
    mutating func invalidate()
}

public typealias QueueID = String
