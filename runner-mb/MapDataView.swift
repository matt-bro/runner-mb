//MIT License
//
//Copyright (c) 2020 Matthias Brodalka
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
import Foundation
import MapKit

class MapDataView: UIView, MKMapViewDelegate {
    var mapView: MKMapView = MKMapView(frame: .zero)

    var locations:[CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude:50.110924, longitude:8.682127),
        CLLocationCoordinate2D(latitude:50.111211, longitude:8.682976),
        CLLocationCoordinate2D(latitude:50.111628, longitude:8.684494),
        CLLocationCoordinate2D(latitude:50.112044, longitude:8.685384),
        CLLocationCoordinate2D(latitude:50.112254, longitude:8.685910),
        CLLocationCoordinate2D(latitude:50.112415, longitude:8.685905),
        CLLocationCoordinate2D(latitude:50.112312, longitude:8.684977),
        CLLocationCoordinate2D(latitude:50.112230, longitude:8.684360),
        CLLocationCoordinate2D(latitude:50.112003, longitude:8.683169),
        CLLocationCoordinate2D(latitude:50.111755, longitude:8.681801),
        CLLocationCoordinate2D(latitude:50.111445, longitude:8.680277),
        CLLocationCoordinate2D(latitude:50.111204, longitude:8.679382)
        ] {
        didSet {
            self.loadMap()
        }
    }

//    override func awakeFromNib() {
//
//    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    convenience init() {
        self.init(frame:.zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {

        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1

        self.addSubview(mapView)

        self.mapView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        loadMap()
    }

    private func mapRegion() -> MKCoordinateRegion? {
//        guard
//            let locations = locations,
//            locations.count > 0
//            else {
//                return nil
//        }

        let latitudes = locations.map { location -> Double in
            let location = location //as! Location
            return location.latitude
        }

        let longitudes = locations.map { location -> Double in
            let location = location //as! Location
            return location.longitude
        }

        if latitudes.isEmpty || longitudes.isEmpty {
            return nil
        }

        let maxLat = latitudes.max()!
        let minLat = latitudes.min()!
        let maxLong = longitudes.max()!
        let minLong = longitudes.min()!

        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLong + maxLong) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3,
                                    longitudeDelta: (maxLong - minLong) * 1.3)
        return MKCoordinateRegion(center: center, span: span)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .red
        renderer.lineWidth = 3
        return renderer
    }

    private func loadMap() {
        guard let region = mapRegion() else {
            return
        }
        mapView.removeOverlays(mapView.overlays)
        mapView.setRegion(region, animated: true)
        mapView.addOverlay(polyLine())
    }

    private func polyLine() -> MKPolyline {
//        guard let locations = locations else {
//            return MKPolyline()
//        }

        let coords: [CLLocationCoordinate2D] = locations.map { location in
            let location = location// as! Location
            return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        }
        return MKPolyline(coordinates: coords, count: coords.count)
    }
}
