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