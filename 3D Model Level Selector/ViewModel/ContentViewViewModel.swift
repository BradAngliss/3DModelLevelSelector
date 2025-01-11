//
//  ModelViewController.swift
//  3D Model Level Selector
//
//  Created by Brad Angliss on 23/04/2024.
//

import Foundation
import SwiftUI
import SceneKit

extension ContentView {
    final class ViewModel: ObservableObject {
        var selectedNode: Nodes = .treeHouse
        var mainScene: SCNScene
        var camera: SCNNode
        var pivot: SCNNode
        var nodeObjects = [SCNNode]()
        var selectedIndex: Int = 0

        @Published var levelTitle: String
        @Published var levelDescription: String
        
        init() {
            let scene = SCNScene(named: "MainScene.scn")!
            mainScene = makeScene(name: "MainScene.scn")!
            camera = setUpCamera()!
            pivot = scene.rootNode.childNode(withName: "pivot", recursively: true)!

            levelTitle = selectedNode.title
            levelDescription = selectedNode.description
            
            mainScene.rootNode.enumerateChildNodes { child, stop in
                if let _ = Nodes(rawValue: child.name!) {
                    child.runAction(.repeatForever(.rotateBy(x: 0, y: -10, z: 0, duration: 15)))
                    nodeObjects.append(child)
                    if child.name == selectedNode.rawValue {
                        selectedIndex = nodeObjects.count - 1
                    }
                }
            }
            
        }
        
        func distanceToNodeFromCamera(node: SCNNode) -> Float {
            let end = node.presentation.worldPosition
            let start = camera.presentation.worldPosition

            let dx = (end.x) - (start.x)
            let dy = (end.y) - (start.y)
            let dz = (end.z) - (start.z)

            return sqrt(pow(dx,2)+pow(dy,2)+pow(dz,2))
        }

        func createBlur(node: SCNNode) -> CIFilter {
            let gaussianBlur    = CIFilter(name: "CIGaussianBlur")
            gaussianBlur?.name  = "blur"
            let blurAmount = distanceToNodeFromCamera(node: node)
            gaussianBlur?.setValue(blurAmount, forKey: "inputRadius")
            return gaussianBlur!
        }
        
        func swipeLeftGesture() {
            let currentNode = nodeObjects[selectedIndex]
            
            selectedIndex += 1
            if selectedIndex > nodeObjects.count - 1 {
                selectedIndex = 0
            }
            selectedNode = Nodes.allCases[selectedIndex]
            
            genericSwipeGesture(currentNode: currentNode)
        }
        
        func swipeRightGesture() {
            let currentNode = nodeObjects[selectedIndex]
            
            selectedIndex -= 1
            if selectedIndex < 0 {
                selectedIndex = nodeObjects.count - 1
            }
            selectedNode = Nodes.allCases[selectedIndex]

            genericSwipeGesture(currentNode: currentNode)
        }

        func angleBetween(nodeOne: SCNNode, nodeTwo: SCNNode) -> CGFloat {
            let previousAngle = atan2f(Float(nodeOne.position.z - pivot.position.z),
                                       Float(nodeOne.position.x - pivot.position.x))
            
            //Calculate the angle from the center of the view to the current touch point.
            let currentAngle = atan2f(Float(nodeTwo.position.z - pivot.position.z),
                                      Float(nodeTwo.position.x - pivot.position.x))
            //Adjust the rotation by the change in angle.
            return CGFloat(currentAngle - previousAngle)
            
        }

        private func genericSwipeGesture(currentNode: SCNNode) {
            let angle = angleBetween(nodeOne: currentNode, nodeTwo: nodeObjects[selectedIndex])
            
            mainScene.rootNode.childNode(withName: "pivot", recursively: true)!.runAction(.rotate(by: angle, around: .init(x: 0, y: 1, z: 0), duration: 0.3))
            
            camera.look(at: nodeObjects[selectedIndex].position)
            
            levelTitle = selectedNode.title
            levelDescription = selectedNode.description
        }
    }

    static func makeScene(name: String) -> SCNScene? {
        return SCNScene(named: name)
    }

    static func setUpCamera() -> SCNNode? {
        let scene = SCNScene(named: "MainScene.scn")!
        let cameraNode = scene.rootNode
            .childNode(withName: "camera", recursively: true)

        return cameraNode
    }

    static func degreesToRadians(_ degrees: Float) -> CGFloat {
        return CGFloat(degrees * .pi / 180)
    }
}
