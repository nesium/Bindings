//
//  ViewModel.swift
//  Bindings
//
//  Created by Marc Bauer on 06/03/2017.
//  Copyright © 2017 nesiumdotcom. All rights reserved.
//

import Foundation
import RxSwift

public protocol ViewModel {
  func setup() -> Single<Void>?
}

public protocol FormViewModel: ViewModel {
  associatedtype T

  func save() -> Single<T>
  func rollback() -> Completable

  var hasChanges: Observable<Bool> { get }
}



extension ViewModel {
  public func setup() -> Single<Void>? {
    return nil
  }
}
