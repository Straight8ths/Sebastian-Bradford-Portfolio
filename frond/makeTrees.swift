//
//  makeTrees.swift
//  Frond
//
//  Created by Sebastian Bradford on 7/19/25.
//

import SwiftUI

// MARK: - AVL Tree (ObservableObject so the UI updates on changes)
final class AVLTree<Value: Comparable>: ObservableObject {
    final class Node: Identifiable {
        let id = UUID()
        var value: Value
        var left: Node?
        var right: Node?
        var height: Int = 1
        
        init(_ value: Value) { self.value = value }
    }
    
    @Published private(set) var root: Node?
    
    // Public API
    func insert(_ value: Value) { root = insert(node: root, value: value) }
    func contains(_ value: Value) -> Bool { contains(node: root, value: value) }
    func remove(_ value: Value) { root = remove(node: root, value: value) }
    func clear() { root = nil }
    
    // MARK: - Private helpers
    private func height(_ node: Node?) -> Int { node?.height ?? 0 }
    private func balance(_ node: Node?) -> Int { height(node?.left) - height(node?.right) }
    
    private func updateHeight(_ node: Node) {
        node.height = max(height(node.left), height(node.right)) + 1
    }
    
    // Rotations
    private func rotateRight(_ y: Node) -> Node {
        guard let x = y.left else { return y }
        let T2 = x.right
        x.right = y
        y.left = T2
        updateHeight(y)
        updateHeight(x)
        return x
    }
    
    private func rotateLeft(_ x: Node) -> Node {
        guard let y = x.right else { return x }
        let T2 = y.left
        y.left = x
        x.right = T2
        updateHeight(x)
        updateHeight(y)
        return y
    }
    
    private func rebalance(_ node: Node) -> Node {
        updateHeight(node)
        let bf = balance(node)
        
        // Left heavy
        if bf > 1 {
            if balance(node.left) < 0 {
                if let left = node.left {
                    node.left = rotateLeft(left) // LR case
                }
            }
            return rotateRight(node) // LL or LR handled
        }
        // Right heavy
        if bf < -1 {
            if balance(node.right) > 0 {
                if let right = node.right {
                    node.right = rotateRight(right) // RL case
                }
            }
            return rotateLeft(node) // RR or RL handled
        }
        return node
    }
    
    // Insert
    private func insert(node: Node?, value: Value) -> Node {
        guard let node = node else { return Node(value) }
        if value < node.value {
            node.left = insert(node: node.left, value: value)
        } else if value > node.value {
            node.right = insert(node: node.right, value: value)
        } else {
            // Duplicate: ignore (or handle as you like)
            return node
        }
        return rebalance(node)
    }
    
    // Search
    private func contains(node: Node?, value: Value) -> Bool {
        guard let node = node else { return false }
        if value == node.value { return true }
        return value < node.value
            ? contains(node: node.left, value: value)
            : contains(node: node.right, value: value)
    }
    
    // Remove (standard BST remove + rebalance on unwind)
    private func remove(node: Node?, value: Value) -> Node? {
        guard let node = node else { return nil }
        
        if value < node.value {
            node.left = remove(node: node.left, value: value)
        } else if value > node.value {
            node.right = remove(node: node.right, value: value)
        } else {
            // node to delete
            if node.left == nil || node.right == nil {
                return node.left ?? node.right // 0 or 1 child
            } else {
                // 2 children: get inorder successor (min in right subtree)
                let successorValue = minValue(node.right!)
                node.value = successorValue
                node.right = remove(node: node.right, value: successorValue)
            }
        }
        return rebalance(node)
    }
    
    private func minValue(_ node: Node) -> Value {
        var cur: Node? = node
        while let next = cur?.left { cur = next }
        return cur!.value
    }
}

// MARK: - Tree Rendering (SwiftUI)
// A node bubble + recursive children with connector lines.
struct AVLNodeView<Value: Comparable>: View {
    let node: AVLTree<Value>.Node
    
    // Tunables for layout
    let horizontalSpacing: CGFloat = 40
    let verticalSpacing: CGFloat = 36
    let bubblePadding: CGFloat = 12
    
    var body: some View {
        VStack(spacing: verticalSpacing) {
            NodeBubble(value: node.value)
            
            // Children row
            if node.left != nil || node.right != nil {
                HStack(alignment: .top, spacing: horizontalSpacing) {
                    if let left = node.left {
                        ConnectedChild {
                            AVLNodeView(node: left)
                        }
                    }
                    if let right = node.right {
                        ConnectedChild {
                            AVLNodeView(node: right)
                        }
                    }
                }
            }
        }
    }
}

// A circular node view
struct NodeBubble<T>: View {
    let value: T
    
    var body: some View {
        Text(String(describing: value))
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .padding(12)
            .background(
                Circle()
                    .fill(Color.blue)
            )
            .foregroundColor(.white)
            .overlay(
                Circle().stroke(Color.black.opacity(0.2), lineWidth: 1)
            )
    }
}

// Wrap a child subtree and draw a simple connector line above it.
// (Vertical connector from parent to just above the child bubble.)
struct ConnectedChild<Content: View>: View {
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Connector path above the child
                Path { path in
                    let w = geo.size.width
                    // Draw a vertical line coming from the parent down towards the child
                    path.move(to: CGPoint(x: w / 2, y: 0))
                    path.addLine(to: CGPoint(x: w / 2, y: 16))
                }
                .stroke(Color.primary.opacity(0.6), lineWidth: 1)
                
                content()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(minWidth: 80, minHeight: 100, alignment: .top) // gives children some space
    }
}

// MARK: - Demo UI
struct makeTrees: View {
    @StateObject private var tree = AVLTree<Int>()
    @State private var inputText: String = ""
    @State private var toRemoveText: String = ""
    
    var body: some View {
        VStack {
            // Controls
            VStack {
                TextField("Insert value", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(maxWidth: 160)
                Button("Insert") {
                    if let v = Int(inputText) {
                        tree.insert(v)
                        inputText = ""
                    }
                }
                Button("Insert random") {
                    let v = Int.random(in: 0...99)
                    tree.insert(v)
                }
                TextField("Remove value", text: $toRemoveText)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(maxWidth: 160)
                Button("Remove") {
                    if let v = Int(toRemoveText) {
                        tree.remove(v)
                        toRemoveText = ""
                    }
                }
                Button(role: .destructive, action: tree.clear) {
                    Text("Clear")
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // Tree canvas
            ScrollView([.vertical, .horizontal]) {
                if let root = tree.root {
                    // Center the tree with padding
                    AVLNodeView(node: root)
                        .padding(24)
                } else {
                    Text("Tree is empty. Insert some values!")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
        .padding(.top)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(minWidth: 600, minHeight: 400)
    }
}

#Preview {
    makeTrees()
}
