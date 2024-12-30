struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Player: UInt32 = 0x1 << 0
    static let Bullet: UInt32 = 0x1 << 1
    static let Enemy: UInt32 = 0x1 << 2
    static let Obstacle: UInt32 = 0x1 << 3
    static let PlayerBullet: UInt32 = 0x1 << 4
}
