# Drivo Platform API Collections Documentation

وثيقة الشرح الكاملة والمفصلة الخاصة بمجموعات الاختبار (Postman Collections) الخاصة بتطبيق وركاب وسائقي **Drivo**.

---

## فهرس المحتويات

1. [مقدمة عن المجموعات](#1-مقدمة-عن-المجموعات)
2. [1. Driver Withdrawal & Settlement Cycle (دورة سحب الأرباح والتسوية)](#1-driver-withdrawal--settlement-cycle)
3. [2. One Trip - On-Demand Ride Cycle (دورة الرحلات الفردية واللحظية)](#2-one-trip---on-demand-ride-cycle)
4. [3. Driver School & University Routes (إدارة خطوط سير المدارس والجامعات للسائق)](#3-driver-school--university-routes)

---

## 1. مقدمة عن المجموعات

تحتوي هذه الوثيقة على تفاصيل الإند بوينتس (Endpoints)، هيدرز الطلب (Headers)، البودي المطلوب (Request Body)، والردود المتوقعة من السيرفر (JSON Responses) لثلاث مجموعات رئيسية:

- **Driver_Withdrawal_Postman_Collection.json**: خاصة باستعلام رصيد السائق، تقديم طلبات سحب الأرباح، ورفع إثبات التحويل وتصفير الحساب من لوحة الآدمن.
- **One_Trip_Ride_Postman_Collection.json**: خاصة بدورة الرحلات الفردية اللحظية (On-Demand Rides) بدءاً من حساب السعر التلقائي، طلب الرحلة بالدفع الرقمي، موافقة السائق، مطابقة كود OTP، وحتى إنهاء الرحلة.
- **Driver_School_University_Postman_Collection.json**: خاصة بإنشاء وتنظيم خطوط سير المدارس والجامعات من تطبيق السائق، متابعة طلبات واشتراكات الركاب وإثباتات الدفع، والقبول والرفض.

---

---

## 2. One Trip - On-Demand Ride Cycle

دورة الرحلات الفردية المباشرة (One Trip) من الحساب التلقائي والتنفيذ والتسوية الرقمية بدون كاش.

### 2.1 حساب التكلفة المقدرة تلقائياً (Get Estimated Fare)

- **Method:** `POST`
- **URL:** `{{base_url}}/api/customer/ride/get-estimated-fare`
- **Headers:**
  - `Authorization`: `Bearer {{customer_token}}`
  - `Content-Type`: `application/json`
  - `Accept`: `application/json`

#### Request Body

```json
{
    "pickup_coordinates": "[30.0444, 31.2357]",
    "destination_coordinates": "[30.0500, 31.2400]",
    "pickup_address": "مدينة نصر - القاهرة",
    "destination_address": "وسط البلد - القاهرة",
    "type": "ride_request"
}
```

#### Response (200 OK)

```json
{
  "response_code": "default_200",
  "message": "Estimated fare calculated successfully",
  "content": {
    "estimated_fare": 120.00,
    "distance_km": 8.5,
    "duration_minutes": 15,
    "base_fare": 20.00,
    "per_km_fare": 11.76,
    "currency": "EGP"
  }
}
```

---

### 2.2 إنشاء طلب رحلة فردية - دفع أونلاين (Create Ride Request)

- **Method:** `POST`
- **URL:** `{{base_url}}/api/customer/ride/create`
- **Headers:**
  - `Authorization`: `Bearer {{customer_token}}`
  - `Content-Type`: `application/json`
  - `Accept`: `application/json`

#### Request Body

```json
{
    "pickup_coordinates": "[30.0444, 31.2357]",
    "destination_coordinates": "[30.0500, 31.2400]",
    "customer_coordinates": "[30.0444, 31.2357]",
    "customer_request_coordinates": "[30.0444, 31.2357]",
    "pickup_address": "مدينة نصر - القاهرة",
    "destination_address": "وسط البلد - القاهرة",
    "estimated_distance": 8.5,
    "estimated_time": 15,
    "estimated_fare": 120.00,
    "vehicle_category_id": "{{vehicle_category_id}}",
    "payment_method": "digital_payment",
    "bid": false,
    "type": "ride_request",
    "note": "رحلة أونلاين بدون كاش"
}
```

#### Response (200 OK)

```json
{
  "response_code": "default_store_200",
  "message": "Ride request created successfully",
  "content": {
    "id": "trip_987123",
    "customer_id": "cust-uuid-456",
    "current_status": "pending",
    "payment_method": "digital_payment",
    "payment_status": "paid",
    "estimated_fare": 120.00,
    "otp": "4892",
    "pickup_address": "مدينة نصر - القاهرة",
    "destination_address": "وسط البلد - القاهرة",
    "created_at": "2026-09-08T15:10:00.000000Z"
  }
}
```

---

### 2.3 متابعة تفاصيل وحالة الرحلة (Get Ride Details)

- **Method:** `GET`
- **URL:** `{{base_url}}/api/customer/ride/details/{{trip_request_id}}`
- **Headers:**
  - `Authorization`: `Bearer {{customer_token}}`
  - `Accept`: `application/json`

#### Response (200 OK)

```json
{
  "response_code": "default_200",
  "message": "Ride details retrieved successfully",
  "content": {
    "id": "trip_987123",
    "current_status": "accepted",
    "otp": "4892",
    "estimated_fare": 120.00,
    "payment_method": "digital_payment",
    "payment_status": "paid",
    "driver": {
      "id": "b9208668-9648-47d2-8d44-d3d411c7dbd3",
      "name": "Ahmed Samir",
      "phone": "+201001234567",
      "rating": 4.9,
      "vehicle": {
        "licence_plate_number": "أ ب ج 1234",
        "brand": "Toyota",
        "model": "Corolla"
      }
    }
  }
}
```

---

### 2.4 عرض الطلبات القريبة والمعلقة للسائق (Pending Ride List)

- **Method:** `GET`
- **URL:** `{{base_url}}/api/driver/ride/pending-ride-list?limit=10&offset=1`
- **Headers:**
  - `Authorization`: `Bearer {{driver_token}}`
  - `Accept`: `application/json`

#### Response (200 OK)

```json
{
  "response_code": "default_200",
  "message": "Pending rides retrieved successfully",
  "content": [
    {
      "id": "trip_987123",
      "customer_name": "Mahmoud Hassan",
      "pickup_address": "مدينة نصر - القاهرة",
      "destination_address": "وسط البلد - القاهرة",
      "estimated_fare": 120.00,
      "estimated_distance": "8.5 km",
      "payment_method": "digital_payment"
    }
  ]
}
```

---

### 2.5 قبول السائق للرحلة (Accept Trip Request)

- **Method:** `POST`
- **URL:** `{{base_url}}/api/driver/ride/trip-action`
- **Headers:**
  - `Authorization`: `Bearer {{driver_token}}`
  - `Content-Type`: `application/json`
  - `Accept`: `application/json`

#### Request Body

```json
{
    "trip_request_id": "{{trip_request_id}}",
    "action": "accepted"
}
```

#### Response (200 OK)

```json
{
  "response_code": "default_update_200",
  "message": "Trip accepted successfully",
  "content": {
    "id": "trip_987123",
    "current_status": "accepted",
    "driver_id": "b9208668-9648-47d2-8d44-d3d411c7dbd3"
  }
}
```

---

### 2.6 مطابقة كود OTP وبدء الرحلة (Match OTP & Start Trip)

- **Method:** `POST`
- **URL:** `{{base_url}}/api/driver/ride/match-otp`
- **Headers:**
  - `Authorization`: `Bearer {{driver_token}}`
  - `Content-Type`: `application/json`
  - `Accept`: `application/json`

#### Request Body

```json
{
    "trip_request_id": "{{trip_request_id}}",
    "otp": "4892"
}
```

#### Response (200 OK)

```json
{
  "response_code": "default_200",
  "message": "OTP matched and trip started successfully",
  "content": {
    "id": "trip_987123",
    "current_status": "ongoing",
    "started_at": "2026-09-08T15:20:00Z"
  }
}
```

---

### 2.7 إنهاء الرحلة بنجاح (Complete Trip)

- **Method:** `PUT`
- **URL:** `{{base_url}}/api/driver/ride/update-status`
- **Headers:**
  - `Authorization`: `Bearer {{driver_token}}`
  - `Content-Type`: `application/json`
  - `Accept`: `application/json`

#### Request Body

```json
{
    "trip_request_id": "{{trip_request_id}}",
    "status": "completed"
}
```

#### Response (200 OK)

```json
{
  "response_code": "default_update_200",
  "message": "Trip completed successfully. Payment processed digitally.",
  "content": {
    "id": "trip_987123",
    "current_status": "completed",
    "paid_amount": 120.00,
    "payment_method": "digital_payment",
    "completed_at": "2026-09-08T15:35:00Z"
  }
}
```
