;; BountyBox - Bug Bounty Payment System
;; A smart contract for managing bug bounty rewards with verified completion

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-amount (err u104))
(define-constant err-already-completed (err u105))
(define-constant err-already-claimed (err u106))

;; Data Variables
(define-data-var bounty-nonce uint u0)

;; Data Maps
(define-map bounties
  { bounty-id: uint }
  {
    creator: principal,
    hunter: (optional principal),
    amount: uint,
    description: (string-ascii 256),
    completed: bool,
    verified: bool,
    claimed: bool
  }
)

;; Read-only functions
(define-read-only (get-bounty (bounty-id uint))
  (map-get? bounties { bounty-id: bounty-id })
)

(define-read-only (get-bounty-nonce)
  (var-get bounty-nonce)
)

;; Public functions

;; Create a new bounty
(define-public (create-bounty (description (string-ascii 256)) (amount uint))
  (let
    (
      (bounty-id (var-get bounty-nonce))
    )
    (asserts! (> amount u0) err-invalid-amount)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set bounties
      { bounty-id: bounty-id }
      {
        creator: tx-sender,
        hunter: none,
        amount: amount,
        description: description,
        completed: false,
        verified: false,
        claimed: false
      }
    )
    (var-set bounty-nonce (+ bounty-id u1))
    (ok bounty-id)
  )
)

;; Assign bounty to a hunter
(define-public (assign-bounty (bounty-id uint) (hunter principal))
  (let
    (
      (bounty (unwrap! (map-get? bounties { bounty-id: bounty-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender (get creator bounty)) err-unauthorized)
    (asserts! (is-eq (get completed bounty) false) err-already-completed)
    (map-set bounties
      { bounty-id: bounty-id }
      (merge bounty { hunter: (some hunter) })
    )
    (ok true)
  )
)

;; Hunter marks bounty as completed
(define-public (submit-completion (bounty-id uint))
  (let
    (
      (bounty (unwrap! (map-get? bounties { bounty-id: bounty-id }) err-not-found))
    )
    (asserts! (is-eq (some tx-sender) (get hunter bounty)) err-unauthorized)
    (asserts! (is-eq (get completed bounty) false) err-already-completed)
    (map-set bounties
      { bounty-id: bounty-id }
      (merge bounty { completed: true })
    )
    (ok true)
  )
)

;; Creator verifies completion
(define-public (verify-completion (bounty-id uint))
  (let
    (
      (bounty (unwrap! (map-get? bounties { bounty-id: bounty-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender (get creator bounty)) err-unauthorized)
    (asserts! (is-eq (get completed bounty) true) err-not-found)
    (asserts! (is-eq (get verified bounty) false) err-already-completed)
    (map-set bounties
      { bounty-id: bounty-id }
      (merge bounty { verified: true })
    )
    (ok true)
  )
)

;; Hunter claims the bounty after verification
(define-public (claim-bounty (bounty-id uint))
  (let
    (
      (bounty (unwrap! (map-get? bounties { bounty-id: bounty-id }) err-not-found))
      (hunter-principal (unwrap! (get hunter bounty) err-not-found))
    )
    (asserts! (is-eq tx-sender hunter-principal) err-unauthorized)
    (asserts! (is-eq (get verified bounty) true) err-unauthorized)
    (asserts! (is-eq (get claimed bounty) false) err-already-claimed)
    (try! (as-contract (stx-transfer? (get amount bounty) tx-sender hunter-principal)))
    (map-set bounties
      { bounty-id: bounty-id }
      (merge bounty { claimed: true })
    )
    (ok true)
  )
)

;; Cancel bounty and refund (only if not completed)
(define-public (cancel-bounty (bounty-id uint))
  (let
    (
      (bounty (unwrap! (map-get? bounties { bounty-id: bounty-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender (get creator bounty)) err-unauthorized)
    (asserts! (is-eq (get completed bounty) false) err-already-completed)
    (try! (as-contract (stx-transfer? (get amount bounty) tx-sender (get creator bounty))))
    (map-delete bounties { bounty-id: bounty-id })
    (ok true)
  )
)