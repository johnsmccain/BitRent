;; BitRent Revenue Split Contract
;; Distributes rental income to fractional NFT holders

(define-constant CONTRACT_OWNER tx-sender)
(define-constant MIN_RENT_AMOUNT u1000000) ;; 1 STX minimum

;; Property revenue tracking
(define-map property-revenue (string-ascii 100) u1000000)
(define-map property-total-fractions (string-ascii 100) u1000)
(define-map user-claimed-revenue principal u1000000)

;; Events (use print for portability)

;; Error codes
(define-constant ERR-UNAUTHORIZED (err u2001))
(define-constant ERR-INSUFFICIENT-RENT (err u2002))
(define-constant ERR-NO-FRACTIONS (err u2003))
(define-constant ERR-NOTHING-TO-CLAIM (err u2004))

;; Public functions

;; Deposit rent for a property
(define-public (deposit-rent (property-id (string-ascii 100)))
  (begin
    (asserts! (>= tx-amount MIN_RENT_AMOUNT) ERR-INSUFFICIENT-RENT)
    
    ;; Add to property revenue
    (map-set property-revenue property-id (+ (default-to u0 (map-get? property-revenue property-id)) tx-amount))
    
    (ok (print (tuple (event "rent-deposited") (property-id property-id) (amount tx-amount) (depositor tx-sender))))
  )
)

;; Set total fractions for a property (called by NFT contract)
(define-public (set-property-fractions (property-id (string-ascii 100)) (total-fractions u1000))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR-UNAUTHORIZED)
    (map-set property-total-fractions property-id total-fractions)
    (ok true)
  )
)

;; Claim revenue for a specific property
(define-public (claim-property-revenue (property-id (string-ascii 100)))
  (let (
    (user-fractions (contract-call? .bitrent-fractional-nft get-user-fractions tx-sender))
    (total-fractions (default-to u0 (map-get? property-total-fractions property-id)))
    (property-revenue-amount (default-to u0 (map-get? property-revenue property-id)))
  )
    (let (
      (user-share (if (> total-fractions u0) (/ (* user-fractions property-revenue-amount) total-fractions) u0))
    )
      (begin
        (asserts! (> user-fractions u0) ERR-NO-FRACTIONS)
        (asserts! (> user-share u0) ERR-NOTHING-TO-CLAIM)
        
        ;; Update claimed revenue
        (map-set user-claimed-revenue tx-sender (+ (default-to u0 (map-get? user-claimed-revenue tx-sender)) user-share))
        
        ;; Transfer STX to user
        (stx-transfer? user-share tx-sender tx-sender)
        
        (ok (print (tuple (event "revenue-claimed") (user tx-sender) (property-id property-id) (amount user-share))))
      )
    )
  )
)

;; Claim all available revenue across all properties
(define-public (claim-all-revenue)
  (let* (
    (total-claimed u0)
    (user-fractions (contract-call? .bitrent-fractional-nft get-user-fractions tx-sender))
  )
    (begin
      (asserts! (> user-fractions u0) ERR-NO-FRACTIONS)
      
      ;; This would iterate through all properties to calculate total claimable
      ;; For simplicity, we'll require users to claim per property
      (ok total-claimed)
    )
  )
)

;; Read-only functions

;; Get property revenue
(define-read-only (get-property-revenue (property-id (string-ascii 100)))
  (ok (default-to u0 (map-get? property-revenue property-id)))
)

;; Get user's claimed revenue
(define-read-only (get-user-claimed-revenue (user principal))
  (ok (default-to u0 (map-get? user-claimed-revenue user)))
)

;; Get property total fractions
(define-read-only (get-property-total-fractions (property-id (string-ascii 100)))
  (ok (default-to u0 (map-get? property-total-fractions property-id)))
)

;; Calculate user's claimable revenue for a property
(define-read-only (calculate-claimable-revenue (user principal) (property-id (string-ascii 100)))
  (let* (
    (user-fractions (contract-call? .bitrent-fractional-nft get-user-fractions user))
    (total-fractions (default-to u0 (map-get? property-total-fractions property-id)))
    (property-revenue-amount (default-to u0 (map-get? property-revenue property-id)))
    (user-share (if (> total-fractions u0) (/ (* user-fractions property-revenue-amount) total-fractions) u0))
  )
    (ok user-share)
  )
)

;; Contract owner functions

;; Withdraw excess STX (emergency function)
(define-public (withdraw-excess-stx)
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR-UNAUTHORIZED)
    (stx-transfer? (stx-get-balance tx-sender) tx-sender tx-sender)
    (ok true)
  )
)
