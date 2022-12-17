import Foundation

open class AsyncState<S, P> {
    private let queue: DispatchQueue
    
    public let notifier = Notifier<P>()
    public private(set) var current: S
    
    public init(state: S, queue: DispatchQueue, initial: ((S) -> (S, P))? = nil) {
        self.current = state
        self.queue = queue
        
        initial.map(process)
    }
    
    public func process(_ f: @escaping (S) -> (S, P)) {
        assert(Thread.isMainThread)
        queue.async {
            let (newState, payload) = f(self.current)
            DispatchQueue.main.sync {
                self.current = newState
                self.notifier.notify(payload)
            }
        }
    }
}
