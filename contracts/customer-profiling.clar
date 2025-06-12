;; Customer Profiling Contract
;; Manages customer preferences and profiles

(define-constant ERR_UNAUTHORIZED (err u200))
(define-constant ERR_PROFILE_NOT_FOUND (err u201))
(define-constant ERR_INVALID_PREFERENCE (err u202))

;; Customer profile structure
(define-map customer-profiles
  { customer: principal }
  {
    age-group: uint,
    interests: (list 10 (string-ascii 20)),
    purchase-history-score: uint,
    engagement-level: uint,
    privacy-level: uint,
    created-at: uint
  }
)

;; Preference categories
(define-map customer-preferences
  { customer: principal, category: (string-ascii 20) }
  { preference-score: uint, last-updated: uint }
)

;; Create or update customer profile
(define-public (create-profile
  (age-group uint)
  (interests (list 10 (string-ascii 20)))
  (privacy-level uint)
)
  (begin
    (asserts! (<= privacy-level u3) ERR_INVALID_PREFERENCE)
    (map-set customer-profiles
      { customer: tx-sender }
      {
        age-group: age-group,
        interests: interests,
        purchase-history-score: u0,
        engagement-level: u1,
        privacy-level: privacy-level,
        created-at: block-height
      }
    )
    (ok true)
  )
)

;; Update customer preference for a category
(define-public (update-preference (category (string-ascii 20)) (score uint))
  (begin
    (asserts! (<= score u100) ERR_INVALID_PREFERENCE)
    (map-set customer-preferences
      { customer: tx-sender, category: category }
      { preference-score: score, last-updated: block-height }
    )
    (ok true)
  )
)

;; Update engagement level
(define-public (update-engagement (customer principal) (level uint))
  (match (map-get? customer-profiles { customer: customer })
    profile-data
    (begin
      (map-set customer-profiles
        { customer: customer }
        (merge profile-data { engagement-level: level })
      )
      (ok true)
    )
    ERR_PROFILE_NOT_FOUND
  )
)

;; Get customer profile
(define-read-only (get-profile (customer principal))
  (map-get? customer-profiles { customer: customer })
)

;; Get customer preference for category
(define-read-only (get-preference (customer principal) (category (string-ascii 20)))
  (map-get? customer-preferences { customer: customer, category: category })
)

;; Check privacy level
(define-read-only (get-privacy-level (customer principal))
  (match (map-get? customer-profiles { customer: customer })
    profile-data (get privacy-level profile-data)
    u0
  )
)
