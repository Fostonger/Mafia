import Foundation

public final class Notifier<Args> {
    private var isBusy = false
    private typealias Func = (Args) -> Void
    private var table = [NSObject: Func]()

    public init() { }
    
    public func notify(_ args: Args) {
        assert(Thread.isMainThread)
        assert(!isBusy, "Sync notifications from handlers are prohibited! It leads to an unpredictable sequence of handlers invocation.")
        
        isBusy = true
        for (_, f) in table {
            f(args)
        }
        isBusy = false
    }
    
    public func subscribe(_ f: @escaping (Args) -> Void) -> NSObject {
        assert(Thread.isMainThread)
        let identity = NSObject()
        table[identity] = f
        return identity
    }
    
    public func unsubscribe(_ identity: NSObject) {
        assert(Thread.isMainThread)
        let v = table.removeValue(forKey: identity)
        assert(v != nil)
    }
    
    @discardableResult
    public func subscribeWeak<O: AnyObject>(_ object: O, _ method: @escaping (O) -> (Args) -> Void) -> NSObject {
        assert(Thread.isMainThread)
        let identity = NSObject()
        table[identity] = { [weak object, unowned self] args in
            if let object = object {
                method(object)(args)
            } else {
                self.unsubscribe(identity)
            }
        }
        return identity
    }
}

extension Notifier where Args == () {
    @discardableResult
    public func subscribeWeak<O: AnyObject>(_ object: O, _ method: @escaping (O) -> () -> Void) -> NSObject {
        assert(Thread.isMainThread)
        let identity = NSObject()
        table[identity] = { [weak object, unowned self] _ in
            if let object = object {
                method(object)()
            } else {
                self.unsubscribe(identity)
            }
        }
        return identity
    }
    
    public func notify() {
        notify(())
    }
}
