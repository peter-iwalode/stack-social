;; StackSocial - Decentralized Reputation & Monetization for Creators
;;
;; Summary:
;; A Bitcoin-secured Clarity smart contract for decentralized creator monetization, 
;; social engagement rewards, and NFT-based reputation and membership systems.
;;
;; Description:
;; StackSocial empowers creators and users in a trustless, Bitcoin-backed ecosystem 
;; on the Stacks L2. By combining a programmable reputation economy, non-fungible 
;; membership tiers, and microtransaction-based engagement incentives, the protocol 
;; enables creators to monetize engagement and build verifiable social capital.
;; 
;; Key features include:
;; - Reputation decay and reward systems
;; - Tip-based engagement with incentives
;; - Mintable NFTs for reputation and tiered membership
;; - Creator-configurable earning parameters
;; - Treasury governance and contract pausing
;; Built with Clarity on Stacks, secured by Bitcoin finality.


;; Error constants
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-ALREADY-EXISTS (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INSUFFICIENT-BALANCE (err u103))
(define-constant ERR-INVALID-AMOUNT (err u104))
(define-constant ERR-INVALID-THRESHOLD (err u105))
(define-constant ERR-INVALID-TIER (err u106))
(define-constant ERR-COOLDOWN-ACTIVE (err u107))
(define-constant ERR-EXPIRED-REPUTATION (err u108))

;; Contract constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant REPUTATION-DECAY-PERIOD u144) ;; ~24 hours in blocks
(define-constant ENGAGEMENT-COOLDOWN u6) ;; ~1 hour in blocks
(define-constant MIN-TIP-AMOUNT u1000000) ;; 1 STX in microSTX
(define-constant MAX-REPUTATION-SCORE u10000)

;; Data variables
(define-data-var contract-paused bool false)
(define-data-var total-reputation-nfts uint u0)
(define-data-var total-membership-nfts uint u0)
(define-data-var treasury-balance uint u0)

;; NFT definitions
(define-non-fungible-token reputation-nft uint)
(define-non-fungible-token membership-nft uint)

;; Data maps
(define-map user-profiles 
  principal 
  {
    reputation-score: uint,
    last-activity-block: uint,
    total-earnings: uint,
    engagement-count: uint,
    reputation-nft-id: (optional uint),
    membership-nft-id: (optional uint)
  }
)

(define-map creator-settings
  principal
  {
    earnings-threshold: uint,
    reward-per-engagement: uint,
    is-active: bool,
    total-distributed: uint
  }
)

(define-map engagement-history
  {user: principal, target: principal, stacks-block-height: uint}
  {
    engagement-type: (string-ascii 20),
    amount: uint,
    processed: bool
  }
)

(define-map membership-tiers
  uint
  {
    tier-name: (string-ascii 50),
    min-reputation: uint,
    benefits: (string-ascii 200),
    access-level: uint
  }
)

(define-map reputation-nft-metadata
  uint
  {
    owner: principal,
    reputation-score: uint,
    minted-at: uint,
    last-updated: uint
  }
)

(define-map membership-nft-metadata
  uint
  {
    owner: principal,
    tier-level: uint,
    granted-at: uint,
    expires-at: (optional uint)
  }
)

;; Helper functions

(define-private (min-uint (a uint) (b uint))
  (if (< a b) a b)
)

(define-private (max-uint (a uint) (b uint))
  (if (> a b) a b)
)

;; Read-only functions

(define-read-only (get-user-profile (user principal))
  (map-get? user-profiles user)
)

(define-read-only (get-creator-settings (creator principal))
  (map-get? creator-settings creator)
)

(define-read-only (get-current-reputation (user principal))
  (let (
    (profile (unwrap! (map-get? user-profiles user) (err u0)))
    (last-activity (get last-activity-block profile))
    (current-block stacks-block-height)
    (blocks-since-activity (- current-block last-activity))
    (base-reputation (get reputation-score profile))
  )
    (if (> blocks-since-activity REPUTATION-DECAY-PERIOD)
      (let ((decay-factor (/ blocks-since-activity REPUTATION-DECAY-PERIOD)))
        (if (>= decay-factor base-reputation)
          (ok u0)
          (ok (- base-reputation (min-uint decay-factor base-reputation)))
        )
      )
      (ok base-reputation)
    )
  )
)

(define-read-only (get-membership-tier (tier-id uint))
  (map-get? membership-tiers tier-id)
)

(define-read-only (get-reputation-nft-info (nft-id uint))
  (map-get? reputation-nft-metadata nft-id)
)

(define-read-only (get-membership-nft-info (nft-id uint))
  (map-get? membership-nft-metadata nft-id)
)

(define-read-only (calculate-tier-for-reputation (reputation uint))
  (if (>= reputation u8000)
    u4 ;; Platinum
    (if (>= reputation u5000)
      u3 ;; Gold
      (if (>= reputation u2000)
        u2 ;; Silver
        u1 ;; Bronze
      )
    )
  )
)

(define-read-only (is-contract-paused)
  (var-get contract-paused)
)

;; Private functions

(define-private (update-reputation-score (user principal) (points uint))
  (let (
    (current-profile (default-to 
      {
        reputation-score: u0,
        last-activity-block: stacks-block-height,
        total-earnings: u0,
        engagement-count: u0,
        reputation-nft-id: none,
        membership-nft-id: none
      }
      (map-get? user-profiles user)
    ))
    (current-reputation (unwrap! (get-current-reputation user) ERR-NOT-FOUND))
    (new-reputation (min-uint (+ current-reputation points) MAX-REPUTATION-SCORE))
  )
    (map-set user-profiles user
      (merge current-profile {
        reputation-score: new-reputation,
        last-activity-block: stacks-block-height,
        engagement-count: (+ (get engagement-count current-profile) u1)
      })
    )
    (ok new-reputation)
  )
)

(define-private (mint-reputation-nft (user principal) (reputation uint))
  (let (
    (nft-id (+ (var-get total-reputation-nfts) u1))
  )
    (try! (nft-mint? reputation-nft nft-id user))
    (map-set reputation-nft-metadata nft-id {
      owner: user,
      reputation-score: reputation,
      minted-at: stacks-block-height,
      last-updated: stacks-block-height
    })
    (var-set total-reputation-nfts nft-id)
    (ok nft-id)
  )
)

(define-private (mint-membership-nft (user principal) (tier uint))
  (let (
    (nft-id (+ (var-get total-membership-nfts) u1))
  )
    (try! (nft-mint? membership-nft nft-id user))
    (map-set membership-nft-metadata nft-id {
      owner: user,
      tier-level: tier,
      granted-at: stacks-block-height,
      expires-at: none
    })
    (var-set total-membership-nfts nft-id)
    (ok nft-id)
  )
)

(define-private (process-engagement-reward (creator principal) (amount uint))
  (let (
    (settings (unwrap! (map-get? creator-settings creator) ERR-NOT-FOUND))
    (reward (get reward-per-engagement settings))
  )
    (if (and (get is-active settings) (> reward u0))
      (begin
        (try! (stx-transfer? reward (as-contract tx-sender) creator))
        (map-set creator-settings creator
          (merge settings {
            total-distributed: (+ (get total-distributed settings) reward)
          })
        )
        (ok reward)
      )
      (ok u0)
    )
  )
)