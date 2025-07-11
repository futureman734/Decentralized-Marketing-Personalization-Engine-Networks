;; Content Customization Contract
;; Manages personalized marketing content

(define-constant ERR_UNAUTHORIZED (err u300))
(define-constant ERR_CONTENT_NOT_FOUND (err u301))
(define-constant ERR_INVALID_CONTENT (err u302))

;; Content template structure
(define-map content-templates
  { template-id: uint }
  {
    creator: principal,
    title: (string-ascii 100),
    category: (string-ascii 20),
    target-age-group: uint,
    content-type: (string-ascii 20),
    effectiveness-score: uint,
    created-at: uint
  }
)

;; Personalized content instances
(define-map personalized-content
  { customer: principal, template-id: uint }
  {
    customized-title: (string-ascii 100),
    personalization-score: uint,
    generated-at: uint,
    interaction-count: uint
  }
)

(define-data-var next-template-id uint u1)

;; Create content template
(define-public (create-template
  (title (string-ascii 100))
  (category (string-ascii 20))
  (target-age-group uint)
  (content-type (string-ascii 20))
)
  (let ((template-id (var-get next-template-id)))
    (map-set content-templates
      { template-id: template-id }
      {
        creator: tx-sender,
        title: title,
        category: category,
        target-age-group: target-age-group,
        content-type: content-type,
        effectiveness-score: u50,
        created-at: block-height
      }
    )
    (var-set next-template-id (+ template-id u1))
    (ok template-id)
  )
)

;; Generate personalized content
(define-public (generate-personalized-content
  (template-id uint)
  (customized-title (string-ascii 100))
)
  (match (map-get? content-templates { template-id: template-id })
    template-data
    (begin
      (map-set personalized-content
        { customer: tx-sender, template-id: template-id }
        {
          customized-title: customized-title,
          personalization-score: u75,
          generated-at: block-height,
          interaction-count: u0
        }
      )
      (ok true)
    )
    ERR_CONTENT_NOT_FOUND
  )
)

;; Record content interaction
(define-public (record-interaction (template-id uint))
  (match (map-get? personalized-content { customer: tx-sender, template-id: template-id })
    content-data
    (begin
      (map-set personalized-content
        { customer: tx-sender, template-id: template-id }
        (merge content-data { interaction-count: (+ (get interaction-count content-data) u1) })
      )
      (ok true)
    )
    ERR_CONTENT_NOT_FOUND
  )
)

;; Get content template
(define-read-only (get-template (template-id uint))
  (map-get? content-templates { template-id: template-id })
)

;; Get personalized content
(define-read-only (get-personalized-content (customer principal) (template-id uint))
  (map-get? personalized-content { customer: customer, template-id: template-id })
)
