import Foundation

precedencegroup ForwardApplication {
    associativity: left
    higherThan: AssignmentPrecedence
}

infix operator |>: ForwardApplication

func |> <A, B> (a: A, f: (A) -> B) -> B {
    return f(a)
}
