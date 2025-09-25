;; Decentralized supply chain and logistics management system
;; Smart Contract for Stacks Blockchain

;; Contract constants
(define-constant contract-coordinator tx-sender)
(define-constant err-coordinator-only (err u500))
(define-constant err-insufficient-clearance (err u501))
(define-constant err-shipment-not-found (err u502))
(define-constant err-supplier-not-exists (err u503))
(define-constant err-logistics-conflict (err u504))
(define-constant err-routing-forbidden (err u505))
(define-constant err-chain-protocol-violation (err u506))
(define-constant err-warehouse-locked (err u507))
(define-constant err-invalid-input (err u508))

;; Data variables
(define-data-var shipment-manifest-counter uint u0)
(define-data-var supplier-network-counter uint u0)
(define-data-var transit-window uint u144) ;; ~24 hours in blocks
(define-data-var logistics-directive-counter uint u0)

;; Core data structures
(define-map shipment-manifest
  { shipment-id: uint }
  {
    cargo-description: (string-ascii 50),
    origin-facility: (string-ascii 100),
    logistics-priority: uint,
    dispatched-by: principal,
    dispatch-block: uint,
    is-transferable: bool,
    delivery-deadline: (optional uint),
    manifest-notes: (string-ascii 200)
  }
)

(define-map supplier-network
  { supplier-id: uint }
  {
    supplier-designation: (string-ascii 50),
    chain-tier: uint,
    upstream-supplier: (optional uint),
    shipment-authorizations: (list 50 uint),
    supply-manager: principal,
    max-capacity: uint,
    current-load: uint,
    routing-enabled: bool,
    supplier-operational: bool
  }
)

(define-map logistics-assignments
  { carrier: principal, supplier-id: uint }
  {
    contracted-by: principal,
    contract-block: uint,
    contract-expiry: (optional uint),
    service-tier: uint,
    contract-terms: (string-ascii 150),
    contract-active: bool,
    last-delivery: uint
  }
)

(define-map routing-chains
  { dispatcher: principal, carrier: principal, shipment-id: uint }
  {
    route-established: uint,
    route-deadline: uint,
    routing-conditions: (string-ascii 100),
    cancellation-authority: principal,
    route-status: bool
  }
)

(define-map warehouse-restrictions
  { facility-id: (string-ascii 100) }
  {
    restricting-authority: principal,
    restriction-period: uint,
    restriction-reason: (string-ascii 150),
    restricted-since: uint,
    clearance-requirements: (string-ascii 200)
  }
)

(define-map logistics-directives
  { directive-id: uint }
  {
    directive-author: principal,
    directive-category: (string-ascii 30),
    target-supplier: (optional uint),
    target-shipment: (optional uint),
    directive-instructions: (string-ascii 300),
    compliance-votes: uint,
    resistance-votes: uint,
    directive-deadline: uint,
    implementation-status: bool
  }
)

;; Input validation functions
(define-private (validate-string-not-empty (str (string-ascii 300)))
  (> (len str) u0)
)

(define-private (validate-logistics-priority (priority uint))
  (<= priority u10) ;; Max priority level of 10
)

(define-private (validate-chain-tier (tier uint))
  (and (>= tier u1) (<= tier u5)) ;; Chain tiers 1-5
)

(define-private (validate-capacity (capacity uint))
  (and (> capacity u0) (<= capacity u1000)) ;; Reasonable capacity limits
)

(define-private (validate-deadline (deadline (optional uint)))
  (match deadline
    deadline-block (> deadline-block block-height)
    true
  )
)

(define-private (validate-restriction-period (period uint))
  (and (> period u0) (<= period u52560)) ;; Max 1 year in blocks (~6 minute blocks)
)

(define-private (validate-directive-duration (duration uint))
  (and (> duration u0) (<= duration u8760)) ;; Max ~2 months in blocks
)

(define-private (validate-transit-window (window uint))
  (and (>= window u6) (<= window u1440)) ;; Between 1 hour and 10 days in blocks
)

;; Private utility functions
(define-private (increment-shipment-counter)
  (let ((current-counter (var-get shipment-manifest-counter)))
    (var-set shipment-manifest-counter (+ current-counter u1))
    (+ current-counter u1)
  )
)

(define-private (increment-supplier-counter)
  (let ((current-counter (var-get supplier-network-counter)))
    (var-set supplier-network-counter (+ current-counter u1))
    (+ current-counter u1)
  )
)

(define-private (increment-directive-counter)
  (let ((current-counter (var-get logistics-directive-counter)))
    (var-set logistics-directive-counter (+ current-counter u1))
    (+ current-counter u1)
  )
)

(define-private (has-shipping-clearance (carrier principal) (shipment-id uint))
  (let ((assignment-exists (is-some (map-get? logistics-assignments { carrier: carrier, supplier-id: u1 }))))
    ;; Simplified check - in production would iterate through carrier's suppliers
    assignment-exists
  )
)

(define-private (validate-chain-tier-access (supplier-id uint) (required-tier uint))
  (match (map-get? supplier-network { supplier-id: supplier-id })
    supplier-data (>= (get chain-tier supplier-data) required-tier)
    false
  )
)

(define-private (is-supply-manager (carrier principal) (supplier-id uint))
  (match (map-get? supplier-network { supplier-id: supplier-id })
    supplier-data (is-eq carrier (get supply-manager supplier-data))
    false
  )
)

(define-private (is-shipment-overdue (shipment-id uint))
  (match (map-get? shipment-manifest { shipment-id: shipment-id })
    shipment-data
    (match (get delivery-deadline shipment-data)
      deadline-block (> block-height deadline-block)
      false
    )
    true
  )
)

;; Core supply chain management functions

;; Create a new shipment manifest
(define-public (forge-shipment-manifest 
  (cargo-description (string-ascii 50))
  (origin-facility (string-ascii 100))
  (logistics-priority uint)
  (is-transferable bool)
  (delivery-deadline (optional uint))
  (manifest-notes (string-ascii 200)))
  (let ((shipment-id (increment-shipment-counter)))
    ;; Input validation
    (asserts! (validate-string-not-empty cargo-description) err-invalid-input)
    (asserts! (validate-string-not-empty origin-facility) err-invalid-input)
    (asserts! (validate-logistics-priority logistics-priority) err-invalid-input)
    (asserts! (validate-deadline delivery-deadline) err-invalid-input)
    
    (map-set shipment-manifest
      { shipment-id: shipment-id }
      {
        cargo-description: cargo-description,
        origin-facility: origin-facility,
        logistics-priority: logistics-priority,
        dispatched-by: tx-sender,
        dispatch-block: block-height,
        is-transferable: is-transferable,
        delivery-deadline: delivery-deadline,
        manifest-notes: manifest-notes
      }
    )
    (ok shipment-id)
  )
)

;; Establish supplier in the network
(define-public (establish-supplier
  (supplier-designation (string-ascii 50))
  (chain-tier uint)
  (upstream-supplier (optional uint))
  (max-capacity uint)
  (routing-enabled bool))
  (let ((supplier-id (increment-supplier-counter)))
    ;; Input validation
    (asserts! (validate-string-not-empty supplier-designation) err-invalid-input)
    (asserts! (validate-chain-tier chain-tier) err-invalid-input)
    (asserts! (validate-capacity max-capacity) err-invalid-input)
    
    ;; Validate upstream supplier exists if provided
    (match upstream-supplier
      upstream-id (asserts! (is-some (map-get? supplier-network { supplier-id: upstream-id })) err-supplier-not-exists)
      true
    )
    
    (map-set supplier-network
      { supplier-id: supplier-id }
      {
        supplier-designation: supplier-designation,
        chain-tier: chain-tier,
        upstream-supplier: upstream-supplier,
        shipment-authorizations: (list),
        supply-manager: tx-sender,
        max-capacity: max-capacity,
        current-load: u0,
        routing-enabled: routing-enabled,
        supplier-operational: true
      }
    )
    (ok supplier-id)
  )
)

;; Grant shipment authorization to supplier
(define-public (grant-supplier-shipment-authorization 
  (supplier-id uint)
  (shipment-id uint))
  (let ((supplier-data (unwrap! (map-get? supplier-network { supplier-id: supplier-id }) err-supplier-not-exists))
        (shipment-data (unwrap! (map-get? shipment-manifest { shipment-id: shipment-id }) err-shipment-not-found)))
    ;; Input validation
    (asserts! (> supplier-id u0) err-invalid-input)
    (asserts! (> shipment-id u0) err-invalid-input)
    
    (if (or (is-eq tx-sender contract-coordinator) 
            (is-supply-manager tx-sender supplier-id))
      (let ((updated-authorizations (unwrap-panic (as-max-len? 
            (append (get shipment-authorizations supplier-data) shipment-id) u50))))
        (map-set supplier-network
          { supplier-id: supplier-id }
          (merge supplier-data { shipment-authorizations: updated-authorizations })
        )
        (ok true)
      )
      err-insufficient-clearance
    )
  )
)

;; Contract carrier to supplier
(define-public (contract-logistics-carrier
  (carrier principal)
  (supplier-id uint)
  (contract-expiry (optional uint))
  (contract-terms (string-ascii 150)))
  (let ((supplier-data (unwrap! (map-get? supplier-network { supplier-id: supplier-id }) err-supplier-not-exists)))
    ;; Input validation
    (asserts! (> supplier-id u0) err-invalid-input)
    (asserts! (validate-string-not-empty contract-terms) err-invalid-input)
    (match contract-expiry
      expiry-block (asserts! (> expiry-block block-height) err-invalid-input)
      true
    )
    
    (if (or (is-eq tx-sender contract-coordinator) 
            (is-supply-manager tx-sender supplier-id))
      (if (< (get current-load supplier-data) (get max-capacity supplier-data))
        (begin
          (map-set logistics-assignments
            { carrier: carrier, supplier-id: supplier-id }
            {
              contracted-by: tx-sender,
              contract-block: block-height,
              contract-expiry: contract-expiry,
              service-tier: u0,
              contract-terms: contract-terms,
              contract-active: true,
              last-delivery: block-height
            }
          )
          (map-set supplier-network
            { supplier-id: supplier-id }
            (merge supplier-data { current-load: (+ (get current-load supplier-data) u1) })
          )
          (ok true)
        )
        err-logistics-conflict
      )
      err-insufficient-clearance
    )
  )
)

;; Establish routing chain
(define-public (establish-routing-chain
  (carrier principal)
  (shipment-id uint)
  (route-deadline uint)
  (routing-conditions (string-ascii 100)))
  (let ((shipment-data (unwrap! (map-get? shipment-manifest { shipment-id: shipment-id }) err-shipment-not-found)))
    ;; Input validation
    (asserts! (> shipment-id u0) err-invalid-input)
    (asserts! (> route-deadline block-height) err-invalid-input)
    (asserts! (validate-string-not-empty routing-conditions) err-invalid-input)
    
    (if (and (get is-transferable shipment-data)
             (has-shipping-clearance tx-sender shipment-id)
             (not (is-shipment-overdue shipment-id)))
      (begin
        (map-set routing-chains
          { dispatcher: tx-sender, carrier: carrier, shipment-id: shipment-id }
          {
            route-established: block-height,
            route-deadline: route-deadline,
            routing-conditions: routing-conditions,
            cancellation-authority: tx-sender,
            route-status: true
          }
        )
        (ok true)
      )
      err-routing-forbidden
    )
  )
)

;; Terminate carrier contract
(define-public (terminate-carrier-contract
  (carrier principal)
  (supplier-id uint))
  (let ((supplier-data (unwrap! (map-get? supplier-network { supplier-id: supplier-id }) err-supplier-not-exists))
        (assignment-data (unwrap! (map-get? logistics-assignments { carrier: carrier, supplier-id: supplier-id }) err-shipment-not-found)))
    ;; Input validation
    (asserts! (> supplier-id u0) err-invalid-input)
    
    (if (or (is-eq tx-sender contract-coordinator) 
            (is-supply-manager tx-sender supplier-id)
            (is-eq tx-sender (get contracted-by assignment-data)))
      (begin
        (map-set logistics-assignments
          { carrier: carrier, supplier-id: supplier-id }
          (merge assignment-data { contract-active: false })
        )
        (map-set supplier-network
          { supplier-id: supplier-id }
          (merge supplier-data { current-load: (- (get current-load supplier-data) u1) })
        )
        (ok true)
      )
      err-insufficient-clearance
    )
  )
)

;; Cancel routing chain
(define-public (cancel-routing-chain
  (carrier principal)
  (shipment-id uint))
  (let ((routing-data (unwrap! (map-get? routing-chains 
    { dispatcher: tx-sender, carrier: carrier, shipment-id: shipment-id }) err-shipment-not-found)))
    ;; Input validation
    (asserts! (> shipment-id u0) err-invalid-input)
    
    (if (is-eq tx-sender (get cancellation-authority routing-data))
      (begin
        (map-set routing-chains
          { dispatcher: tx-sender, carrier: carrier, shipment-id: shipment-id }
          (merge routing-data { route-status: false })
        )
        (ok true)
      )
      err-insufficient-clearance
    )
  )
)
