import Foundation

public typealias AsyncStateUpdate<S, P> = (S) -> (S, P)

open class AsyncState<S, P> {
    private let queue: DispatchQueue
    private var enqueued = 0
    
    public let notifier = Notifier<P>()
    public private(set) var current: S
    
    public var synced: S? {
        enqueued > 0 ? nil : current
    }
    
    public init(state: S, queue: DispatchQueue, initial: AsyncStateUpdate<S, P>? = nil) {
        self.current = state
        self.queue = queue
        
        initial.map(process)
    }
    
    public func process(_ f: @escaping AsyncStateUpdate<S, P>) {
        assert(Thread.isMainThread)
        enqueued += 1
        queue.async {
            let (newState, payload) = f(self.current)
            DispatchQueue.main.sync {
                self.enqueued -= 1
                self.current = newState
                self.notifier.notify(payload)
            }
        }
    }
}
