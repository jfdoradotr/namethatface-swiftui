//
// Copyright © Juan Francisco Dorado Torres. All rights reserved.
//

import CoreLocation
import Foundation
import SwiftData
import UIKit

@Model
class Face: Hashable, Decodable {
  var id: UUID
  @Attribute(.externalStorage) var data: Data
  var name: String
  var latitude: Double?
  var longitude: Double?

  var uiImage: UIImage { UIImage(data: data)! }
  var coordinates: CLLocationCoordinate2D? {
    guard let latitude, let longitude else { return nil }
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }

  init(id: UUID, data: Data, name: String, latitude: Double?, longitude: Double?) {
    self.id = id
    self.data = data
    self.name = name
    self.latitude = latitude
    self.longitude = longitude
  }

  // MARK: Decodable

  private enum CodingKeys: CodingKey {
    case id, data, name, latitude, longitude
  }

  required init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(UUID.self, forKey: .id)
    self.data = try container.decode(Data.self, forKey: .data)
    self.name = try container.decode(String.self, forKey: .name)
    self.latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
    self.longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
  }
}
