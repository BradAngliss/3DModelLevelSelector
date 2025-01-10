//
//  ViewModel+LevelModel.swift
//  3D Model Level Selector
//
//  Created by Brad Angliss on 10/01/2025.
//

enum Nodes: String, CaseIterable {
    case treeHouse = "tree_ref"
    case fantasyHouse = "fantasy_ref"
    case medievalHouse = "medieval_ref"
    case chineseHouse = "chinese_buliding_ref"

    var title: String {
        switch self {
        case .treeHouse:
            "Treetop Stronghold"
        case .fantasyHouse:
            "Mythic Township Revival"
        case .medievalHouse:
            "Spectral Echoes"
        case .chineseHouse:
            "Echoes of the Dynasty"
        }
    }

    var description: String {
        switch self {
        case .treeHouse:
            "Conquer guardians, climb branches, unveil secrets in this enchanted medieval treehouse adventure."
        case .fantasyHouse:
            "Embark on quests to gather resources, recruit allies, and fortify your fantasy town against impending threats."
        case .medievalHouse:
            "Explore the haunting ruins, uncover dark secrets, and confront spectral entities in this desolate medieval house."
        case .chineseHouse:
            "Navigate ancient halls, decipher puzzles, and confront legendary spirits in this mystical Chinese adventure."
        }
    }
}
