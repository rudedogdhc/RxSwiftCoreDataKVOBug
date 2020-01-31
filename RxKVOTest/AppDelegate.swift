import UIKit
import CoreData
import RxSwift
import RxCocoa

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    testObserver()
    return true
  }

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
  }

  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "RxKVOTest")
    let store = NSPersistentStoreDescription()
    store.type = NSInMemoryStoreType
    container.persistentStoreDescriptions = [store]
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()

  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }

  let disposeBag = DisposeBag()

  func show(observable: Observable<NSSet>, prefix: String) {
    observable
      .map { $0.compactMap { $0 as? Pet }}
      .map { $0.map { $0.name ?? "<unknown>"}.sorted() }
      .map { $0.joined(separator: ",")}
      .subscribe(onNext: {names in print("\(prefix): |\(names)|")})
      .disposed(by: disposeBag)
  }

  func testObserver() {
    let person = Person(context: persistentContainer.viewContext)
    person.personName = "a person"

    // Create an observable using rx.observe
    let rxObserver = person.rx.observe(NSSet.self, "pets")
      .map { $0 ?? NSSet() }

    show(observable: rxObserver, prefix: "rx.observe")

    // Create an observable using native Swift KVO.
    let kvoObservable = Observable<NSSet>.create { subscribe in
      let observer = person.observe(\.pets, options: .initial) { person, _ in
        subscribe.on(.next(person.pets ?? NSSet()))
      }

      return Disposables.create {
        observer.invalidate()
      }
    }

    show(observable: kvoObservable, prefix: "direct KVO")

    let pets = (0..<10).map {ndx -> Pet in
      let result = Pet(context: persistentContainer.viewContext)
      result.name = "pet\(ndx)"
      return result
    }

    print()

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      print("person.pets = pet0")
      person.pets = NSSet(object: pets[0])
      print()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      print("person.pets = pet0,pet1")
      person.pets = NSSet(array: [pets[0], pets[1]])
      print()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      print("person.addToPets(pet2)")
      person.addToPets(pets[2])
      print()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
      print("person.addToPets(pet3)")
      person.addToPets(pets[3])
      print()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
      print("person.removeFromPets(pet0)")
      person.removeFromPets(pets[0])
      print()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
      print("person.addToPets(pet4,pet5)")
      person.addToPets(NSSet(array: [pets[4], pets[5]]))
      print()
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
      print("person.removeFromPets(pet2,pet3)")
      person.removeFromPets(NSSet(array: [pets[2], pets[3]]))
      print()
    }
  }
}

