# PayMob SDK Backend Integration Specification (Drivo App)

This document outlines the backend APIs, payment intention/token generation, webhooks, and database structure required for the **PayMob Flutter Mobile SDK Integration**.

---

## 1. Architecture Overview (Intention / SDK Token Flow)

Instead of webview iFrame redirects, the app uses the **Native PayMob Mobile SDK**.

```
+----------------+          +-------------------+          +-------------------+          +------------------+
|  Flutter App   |          |   Drivo Backend   |          |    PayMob API     |          |  PayMob Flutter  |
|                |          |                   |          |                   |          |       SDK        |
+----------------+          +-------------------+          +-------------------+          +------------------+
        |                             |                              |                             |
        | --- 1. Request Intent ----> |                              |                             |
        |     (trip_id, tips)         |                              |                             |
        |                             | --- 2. Create Intention/ --->|                             |
        |                             |     Payment Key              |                             |
        |                             | <-- 3. Return client_secret -|                             |
        |                             |        / payment_token       |                             |
        |                             |                              |                             |
        | <-- 4. Return SDK Token --- |                              |                             |
        |     (client_secret/token)   |                              |                             |
        |                                                                                          |
        | =========================== 5. Launch PayMob Native SDK =============================> |
        |                              (Pass client_secret / payment_token & public_key)           |
        |                                                                                          |
        | <========================== 6. Native Payment Completed / Result ====================== |
        |                             |                                                            |
        |                             | <--- 7. Webhook Callback ----------------------------------|
        |                             |      (Updates trip status to 'paid')                       |
+----------------+          +-------------------+          +-------------------+          +------------------+
```

---

## 2. PayMob Dashboard & Credentials (`.env`)

The backend must store the following PayMob credentials securely:

```env
PAYMOB_SECRET_KEY=secret_key_xxxxxxx   # Used for backend API calls
PAYMOB_PUBLIC_KEY=public_key_xxxxxxx   # Returned to Flutter client or used for initialization
PAYMOB_INTEGRATION_ID=123456           # Card / Wallet Integration ID
PAYMOB_HMAC_SECRET=hmac_secret_xxxxxxx # Used to verify Webhook callbacks
```

---

## 3. Required Backend API Endpoints

### A. Intention / Payment Key Generation Endpoint

* **URL:** `POST /api/customer/ride/paymob-intent`
* **Headers:** `Authorization: Bearer <user_token>`
* **Request Body:**
```json
{
  "trip_request_id": "1234",
  "tips": "10.0"
}
```

* **Backend Processing Logic:**
  1. Retrieve trip details and calculate total amount in cents:
     `amount_cents = (trip.final_fare + tips) * 100`
  2. Call PayMob **Intention API** or **Authentication + Order + Payment Key API**:

     **Option A: PayMob Unified Intention API (Recommended for modern SDK):**
     `POST https://accept.paymob.com/v1/intention/`
     Headers: `Authorization: Token PAYMOB_SECRET_KEY`
     Payload:
     ```json
     {
       "amount": 15000,
       "currency": "EGP",
       "payment_methods": [YOUR_PAYMOB_INTEGRATION_ID],
       "billing_data": {
         "first_name": "Customer",
         "last_name": "User",
         "phone_number": "+201000000000",
         "email": "customer@drivoeg.com"
       },
       "special_reference": "TRIP_1234"
     }
     ```
     *Response contains:* `client_secret` (or payment token).

     **Option B: Standard Payment Key Flow:**
     - Step 1: `POST https://accept.paymob.com/api/auth/tokens` with `api_key`.
     - Step 2: `POST https://accept.paymob.com/api/ecommerce/orders` with `amount_cents` & `merchant_order_id`.
     - Step 3: `POST https://accept.paymob.com/api/acceptance/payment_keys` with `integration_id`, `order_id`, and `billing_data`.

* **API Success Response to Flutter App:**
```json
{
  "status": "success",
  "message": "Payment token generated successfully",
  "data": {
    "client_secret": "cl_sec_xxxxxxxxxxxx",
    "public_key": "public_key_xxxxxxx",
    "amount_cents": 15000,
    "currency": "EGP"
  }
}
```

---

### B. Transaction Webhook / Callback (CRITICAL)

Set up a webhook listener for PayMob transaction status updates.

* **URL:** `POST /api/customer/ride/paymob-webhook`
* **HMAC Verification:**
  - PayMob sends an `hmac` parameter in the request query/body.
  - Calculate HMAC-SHA512 of specific payload fields in alphabetical order using `PAYMOB_HMAC_SECRET`.
  - Reject requests with invalid HMAC signatures.
* **Database Updates:**
  - If `success` is `true`:
    1. Mark `trip_request` payment status as `paid`.
    2. Save transaction reference and gateway (`paymob`).
    3. Push real-time event / FCM notification to rider & driver.
  - If `success` is `false`: Log failed payment attempt.

---

## 4. Configuration API Update

Ensure `/api/customer/configuration` includes `paymob` in the active gateways array:

```json
{
  "payment_gateways": [
    {
      "gateway": "paymob",
      "gateway_title": "PayMob (Cards & Wallets)",
      "gateway_image": "paymob.png"
    }
  ]
}
```
