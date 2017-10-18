//
//  Copyright (c) 2017. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

/// The base class for all components. A component defines private properties a RIB provides to
/// its internal router, interactor, presenter and view units, as well as public properties to its child
/// RIBs. A component subclass implementation should conform to child 'Dependency' protocols, defined
/// by all of its immediate children.
open class Component<DependencyType>: Dependency {

    /// The dependency of this component.
    open let dependency: DependencyType

    /// Initializer.
    ///
    /// - parameter dependency: The dependency of this component, usually provided by the parent
    /// component.
    public init(dependency: DependencyType) {
        self.dependency = dependency
    }

    /// Used to create a shared dependency in your `Component` sub-class. Shared dependencies are retained
    /// and reused by the component. Each dependent asking for this dependency will receive the same instance while
    /// the component is alive.
    ///
    /// - note: Any shared dependency's constructor may not switch threads as this might cause a deadlock.
    ///
    /// - parameter factory: The closure to construct the dependency.
    /// - returns: The instance.
    public final func shared<T>(__function: String = #function, _ factory: () -> T) -> T {
        // Use function name as the key, since this is unique per component class. At the same time,
        // this is also 150 times faster than interpolating the type to convert to string, `"\(T.self)"`.
        return lock.synchronize {
            if let instance = sharedInstances[__function] as? T {
                return instance
            }

            let instance = factory()
            sharedInstances[__function] = instance

            return instance
        }
    }

    // Shared lock between component and eager Initialize component.
    let lock = RecursiveSyncLock()

    // MARK: - Private

    private var sharedInstances = [String: Any]()
}

/// The special empty component.
open class EmptyComponent: EmptyDependency {

    /// Initializer.
    public init() {}
}
