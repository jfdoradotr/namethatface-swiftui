//
// Copyright © Juan Francisco Dorado Torres. All rights reserved.
//

import Foundation
import SwiftData
import UIKit

@Model
class Face: Hashable, Decodable {
  var id: UUID
  @Attribute(.externalStorage) var data: Data
  var name: String

  var uiImage: UIImage { UIImage(data: data)! }

  init(id: UUID, data: Data, name: String) {
    self.id = id
    self.data = data
    self.name = name
  }

  // MARK: Decodable

  private enum CodingKeys: CodingKey {
    case id, data, name
  }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(UUID.self, forKey: .id)
    self.data = try container.decode(Data.self, forKey: .data)
    self.name = try container.decode(String.self, forKey: .name)
  }
}
