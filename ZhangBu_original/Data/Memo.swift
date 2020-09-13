////
////  Memo.swift
////  ZhangBu_original
////
////  Created by Kiichi Ikeda on 2020/08/15.
////  Copyright © 2020 net.Chee-Saga. All rights reserved.
////
//import Foundation
//import RealmSwift
//
//class Memo: Object {
//
//    @objc dynamic private var id: Int = 0
//    @objc dynamic var addDate: Date = Date()
//    @objc dynamic var category: String = ""
//    @objc dynamic var memo: String = ""
//    
//    
//    static func lastId() -> Int {
//        let realm = try! Realm()
//        if let object = realm.objects(Memo.self).last {
//            return object.id + 1
//        } else {
//            return 1
//        }
//    }
//    
//    // 作成(Create)のためのコード
//    static func create() -> Memo {
//        let payment = Memo()
//        payment.id = lastId()
//        return payment
//    }
//    
//    
//    // データを保存するためのコード
//    func save() {
//        let realm = try! Realm()
//        try! realm.write() {
//            realm.add(self)
//        }
//    }
//    
//    func example1() {
//        
//        Memo.create() //-> ⭕️
//        
//        let memo = Memo()
//        memo.create() //-> ❌
//        
//    }
//    
//    func example2() {
//        
//        Memo.save(<#T##self: Memo##Memo#>) //-> 🔺
//        
//        let memo = Memo()
//        memo.save() //-> ⭕️
//        
//    }
//    
//    static func read() -> [Memo] {
//        
//        let realm = try! Realm()
//        
//        let memos = realm.objects(Memo.self) //-> Results<Memo>
//        
//        let memoArray1: [Memo] = realm.objects(Memo.self) //-> ❌
//        
//        let memoArray2: [Memo] = realm.objects(Memo.self) + [] //-> ⭕️
//    }
//    
//    
//    static func selectRead(category: String) -> [Memo] {
//        
//        let realm = try! Realm()
//        
//        let memos: Results<Memo> = realm.objects(Memo.self) //-> Results<Memo>
//        
//        let memoArray = memos.filter("memo = \(category)") + [] //-> [Memo]
//        
//        return memoArray
//        
//    }
//    
//    
//    func example3() {
//        
//        let selectedMemos = Memo.selectRead(category: <#T##String#>) //<-呼び出したいメモの種類を代入してあげる
//        
//    }
//    
//    func example4() {
//        let realm = try! Realm()
//        
//        let memo = Memo()
//        
//        let oneMemo = Memo.read()
//        
//        memo.memo = "広瀬すずさんを見た" //-> ⭕️
//        oneMemo[0].memo = "広瀬すずさんを見た" //-> ❌
//        
//        
//        try! realm.write() {
//            oneMemo[0].memo = "広瀬すずさんを見た" //-> ⭕️
//        }
//        
//    }
//    
//    func example5() {
//        
//        let memo = Memo.create()
//        memo.memo = "メモを入力"
//        memo.category = ""
//        memo.addDate = Date()
//        
//    }
// 
//    func test() {
//        print("test")
//        print(memo) //-> ⭕️
//    }
//    
//    static func test1() {
//        print("test1")
//        print(memo) //-> ❌
//    }
//    
//    func test2() {
//        test()
//        Memo.test1()
//    }
//    
//    
//    
//}
//
//class Meno2 {
//
//    func test() {
//        
//        let memo = Memo()
//        memo.test()
//        memo.test1() //->　❌
//        Memo.test1() //-> ⭕️
//    }
//    
//    
//}
//    
//    
//    
//    
//    
//    
//    
//}
//
