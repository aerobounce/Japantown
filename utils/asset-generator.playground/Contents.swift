import MapKit
import PlaygroundSupport
import UIKit

extension UIView {
    var pngData: Data {
        return UIGraphicsImageRenderer(size: bounds.size)
            .pngData { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
    }
}

let data = CGDataProvider(
    url: Bundle.main.url(
        forResource: "Japantown-Regular",
        withExtension: "otf"
    )! as CFURL
)!
let cgFont = CGFont(data)!
CTFontManagerRegisterGraphicsFont(cgFont, nil)

let mapView: MKMapView = {
    let rect = CGRect(x: 0, y: 0, width: 400, height: 400)
    let mapView = MKMapView(frame: rect)
    mapView.layer.masksToBounds = true
    mapView.layer.borderColor = UIColor.red.cgColor
    mapView.layer.borderWidth = 22
    mapView.layer.cornerRadius = mapView.bounds.width / 2
    mapView.showsBuildings = false
    mapView.pointOfInterestFilter = MKPointOfInterestFilter.excludingAll

    let japantownCoordinates = CLLocationCoordinate2DMake(
        37.785559,
        -122.429817
    )

    mapView.camera = MKMapCamera(
        lookingAtCenter: japantownCoordinates,
        fromDistance: CLLocationDistance(integerLiteral: 10500),
        pitch: 0,
        heading: CLLocationDirection(-9.5)
    )

    let annotation = MKPointAnnotation()
    annotation.coordinate = japantownCoordinates
    annotation.title = "Japantown"

    mapView.addAnnotation(annotation)

    return mapView
}()

let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.distribution = .fill
    stackView.axis = .vertical
    stackView.addArrangedSubview(mapView)

    for index in 0 ... 1 {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont(
            name: "Japantown-Regular",
            size: index == 0 ? 36 : 24
        )
        label.text = index == 0 ? "Japantown" : "ジャパンタウン"
        label.sizeToFit()
        stackView.addArrangedSubview(label)
    }

    let height = stackView.arrangedSubviews
        .reduce(into: CGFloat(0)) { result, view in
            result += view.bounds.height
        }

    stackView.frame = CGRect(x: 0, y: 0, width: 400, height: height)

    return stackView
}()

let wrapperView = UIView(frame: stackView.bounds)
wrapperView.backgroundColor = .white
wrapperView.addSubview(stackView)

// PlaygroundPage.current.liveView = wrapperView

DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    let destination = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("logo.png", isDirectory: false)
    try! wrapperView.pngData.write(to: destination)
    print(destination.deletingLastPathComponent().path)
}

let label = UILabel(frame: CGRect(x: 0, y: 0, width: 800, height: 300))
label.backgroundColor = .white
label.textAlignment = .center
label.numberOfLines = 0
label.font = UIFont(name: "Japantown-Regular", size: 24)
label
    .text = "Japantown-Regular 24px\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
let destination = FileManager.default
    .urls(for: .documentDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("lorem.png", isDirectory: false)
try! label.pngData.write(to: destination)

let label2 = UILabel(frame: CGRect(x: 0, y: 0, width: 800, height: 300))
label2.backgroundColor = .white
label2.textAlignment = .center
label2.numberOfLines = 0
label2.font = UIFont(name: "Japantown-Regular", size: 24)
label2
    .text = "Japantown-Regular 24px\n\nあのイーハトーヴォのすきとおった風、夏でも底に冷たさをもつ青いそら、うつくしい森で飾られたモーリオ市、郊外のぎらぎらひかる草の波。またそのなかでいっしょになったたくさんのひとたち、ファゼーロとロザーロ、羊飼のミーロや、顔の赤いこどもたち、地主のテーモ、山猫博士のボーガント・テストゥパーゴなど、いまこの暗い巨きな石の建物のなかで考えていると、みんなむかし風のなつかしい青い幻燈のように思われます。"
let destination2 = FileManager.default
    .urls(for: .documentDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("jp.png", isDirectory: false)
try! label2.pngData.write(to: destination2)
