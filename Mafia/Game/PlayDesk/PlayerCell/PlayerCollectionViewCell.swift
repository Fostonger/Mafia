import UIKit
import SnapKit

class PlayerCollectionViewCell: UICollectionViewCell {
    private let profileImage: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .podkovaFont(size: 16, type: .regular)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(user: User, image: UIImage, isDead: Bool) {
        nameLabel.text = user.username
        profileImage.image = image
        if isDead {
            drawCross()
        }
    }
    
    private func setupViews() {
        addSubview(profileImage)
        addSubview(nameLabel)
        profileImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(25/2)
            make.trailing.equalToSuperview().inset(25/2)
            make.bottom.equalToSuperview().inset(25)
            make.height.equalTo(frame.height-25)
        }
        nameLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(25)
        }
    }
    
    private func drawCross() {
        if var image = profileImage.image {
            image = image |> convertToGrayScale
            UIGraphicsBeginImageContext(image.size)
            image.draw(at: CGPoint.zero)
            let context = UIGraphicsGetCurrentContext()!

            context.setLineWidth(4.0)
            context.setStrokeColor(UIColor.red.cgColor)
            context.move(to: CGPoint(x: 0, y: 0))
            context.addLine(to: CGPoint(x: image.size.width, y: image.size.height))
            context.strokePath()
            context.move(to: CGPoint(x: 0, y: image.size.height))
            context.addLine(to: CGPoint(x: image.size.width, y: 0))
            context.strokePath()
            let myImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            profileImage.image = myImage
        }
    }
    
    private func convertToGrayScale(image: UIImage) -> UIImage {

        let imageRect:CGRect = CGRect(x:0, y:0, width:image.size.width, height: image.size.height)

        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = image.size.width
        let height = image.size.height

        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)

        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(image.cgImage!, in: imageRect)
        let imageRef = context!.makeImage()

        let newImage = UIImage(cgImage: imageRef!)

        return newImage
    }
}
