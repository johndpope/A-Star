//
//  Node.swift
//  aStar
//
//  Created by Damiaan Dufaux on 19/08/16.
//  Copyright © 2016 Damiaan Dufaux. All rights reserved.
//

public protocol GraphNode: Hashable {

    
    /**
     * List of other graph nodes that this node has an edge leading to.
     */
    var connectedNodes: Set<Self> { get }
    
    
    /**
     * Add a connection to a group of other nodes indicating those nodes can be reached from this node.
     * A new connection is not created if it already exists.
     * @param array of nodes that are end points for their respective connections
     * @param bidirectional should a connection also be added connecting the destination node back to this node?
     */
    // func addConnections(to nodes: [GraphNode], bidirectional: Bool)
    
    
    /**
     * Removes connections to a group of other nodes indicating those nodes can no longer be reached from this node.
     * Nothing happens if a particular connection does not exist.
     * @param node the end point of the edge to be removed
     * @param bidirectional should the connection also be added the destination node back to this node also be removed if it exists?
     */
    // func removeConnections(to nodes: [GraphNode], bidirectional: Bool)
    
    
    /**
     * Returns the estimated heuristic cost to reach the indicated node from this node
     * @param node the end point of the edge who's cost is to be estimated
     */
    func estimatedCost(to node: Self) -> Float
    
    
    /**
     * Returns the actual cost to reach the indicated node from this node
     */
    func cost(to node: Self) -> Float

}

class Step<Node: GraphNode> {
    var node: Node
    var previous: Step<Node>?
    
    var stepCost: Float
    var goalCost: Float
    
    init(from start: Node, to destination: Node, goal: Node) {
        node = destination
        stepCost = start.cost(to: destination)
        goalCost = destination.cost(to: goal)
    }
    
    init(destination: Node, previous: Step<Node>, goal: Node) {
        (node, self.previous) = (destination, previous)
        stepCost = previous.stepCost + previous.node.cost(to: destination)
        goalCost = destination.cost(to: goal)
    }
    
    func cost() -> Float {
        return stepCost + goalCost
    }
    
}

extension Step: Hashable, Equatable, Comparable {
    var hashValue: Int {
        return node.hashValue
    }
    
    static func ==(lhs: Step, rhs: Step) -> Bool {
        return lhs.node == rhs.node
    }
    
    public static func <(lhs: Step, rhs: Step) -> Bool {
        return lhs.cost() < rhs.cost()
    }
    
    public static func <=(lhs: Step, rhs: Step) -> Bool {
        return lhs.cost() <= rhs.cost()
    }
    
    public static func >=(lhs: Step, rhs: Step) -> Bool {
        return lhs.cost() >= rhs.cost()
    }
    
    public static func >(lhs: Step, rhs: Step) -> Bool {
        return lhs.cost() > rhs.cost()
    }

}

extension GraphNode {
    /**
     * Attempts to find the optimal path between this node and the indicated goal node.
     * If such a path exists, it is returned in start to end order.
     * If it doesn't exist, the array returned will be empty.
     * @param goalNode the goal node of the pathfinding attempt
     */
    public func findPath(to goalNode: Self) -> [Self] {
        var possibleSteps = [Step<Self>]()
        var eliminatedNodes: Set = [self]
        
        for connectedNode in connectedNodes {
            let step = Step(from: self, to: connectedNode, goal: goalNode)
            possibleSteps.sortedInsert(newElement: step)
        }
        
        var path = [self]
        while !possibleSteps.isEmpty {
            let step = possibleSteps.removeFirst()
            if step.node == goalNode {
                var cursor = step
                path.insert(step.node, at: 1)
                while let previous = cursor.previous {
                    cursor = previous
                    path.insert(previous.node, at: 1)
                }
                break
            }
            eliminatedNodes.insert(step.node)
            let nextNodes = step.node.connectedNodes.subtracting(eliminatedNodes)
            for node in nextNodes {
                // TODO don't generate a step because in some cases it is never used
                let nextStep = Step(destination: node, previous: step, goal: goalNode)
                let index = possibleSteps.binarySearch(element: nextStep)
                if index<possibleSteps.count && possibleSteps[index] == nextStep {
                    if nextStep.stepCost < possibleSteps[index].stepCost {
                        possibleSteps[index].previous = step
                    }
                } else {
                    possibleSteps.sortedInsert(newElement: nextStep)
                }
            }
        }
        
        return path
    }
    
    
    /**
     * As with findPathToNode: except this node is the goal node and a startNode is specified
     * @param startNode the start node of the pathfinding attempt
     */
    public func findPath(from startNode: Self) -> [Self] {
        return startNode.findPath(to: self)
    }
}
