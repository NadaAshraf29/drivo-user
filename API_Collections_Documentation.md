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

## 1. Driver Withdrawal & Settlement Cycle

مجموعة اختبار دورة سحب الأرباح وتصفير المديونيات بين السائق والآدمن.

### 1.1 استعلام رصيد ومديونية السائق (Driver Profile & Balance)
- **Method:** `GET`
- **URL:** `{{base_url}}/api/driver/info`
- **Headers:**
  - `Authorization`: `Bearer {{driver_token}}`
  - `Accept`: `application/json`

#### Response (200 OK)
```json
{
  "response_code": "default_200",
  "message": "Driver profile and balance retrieved successfully",
  "content": {
    "id": "b9208668-9648-47d2-8d44-d3d411c7dbd3",
    "first_name": "Ahmed",
    "last_name": "Samir",
    "email": "driver@drivoeg.com",
    "phone": "+201001234567",
    "user_account": {
      "receivable_balance": 1250.00,
      "payable_balance": 0.00,
      "pending_balance": 500.00,
      "total_withdrawn": 3500.00
    }
  }
}
```

---

### 1.2 عرض وسائل السحب المتاحة (Get Withdraw Methods)
- **Method:** `GET`
- **URL:** `{{base_url}}/api/driver/withdraw/methods?limit=10&offset=1`
- **Headers:**
  - `Authorization`: `Bearer {{driver_token}}`
  - `Accept`: `application/json`

#### Response (200 OK)
```json
{
  "response_code": "default_200",
  "message": "Withdrawal methods retrieved successfully",
  "content": [
    {
      "id": "wm_vodafone_cash",
      "method_name": "Vodafone Cash",
      "method_fields": [
        {
          "input_name": "phone_number",
          "placeholder": "Enter Vodafone Cash Number"
        }
      ],
      "is_active": 1
    },
    {
      "id": "wm_instapay",
      "method_name": "InstaPay",
      "method_fields": [
        {
          "input_name": "instapay_handle",
          "placeholder": "Enter InstaPay IPA or Mobile"
        }
      ],
      "is_active": 1
    }
  ]
}
```

---

### 1.3 إنشاء طلب سحب جديد (Create Withdraw Request)
- **Method:** `POST`
- **URL:** `{{base_url}}/api/driver/withdraw/request`
- **Headers:**
  - `Authorization`: `Bearer {{driver_token}}`
  - `Content-Type`: `application/json`
  - `Accept`: `application/json`

#### Request Body
```json
{
    "withdraw_method": "wm_vodafone_cash",
    "amount": 500,
    "phone_number": "01012345678",
    "note": "طلب سحب المستحقات عبر فودافون كاش"
}
```

#### Response (200 OK)
```json
{
  "response_code": "default_store_200",
  "message": "Withdrawal request submitted successfully",
  "content": {
    "id": "req_w_987654",
    "user_id": "b9208668-9648-47d2-8d44-d3d411c7dbd3",
    "amount": 500.00,
    "method_id": "wm_vodafone_cash",
    "method_fields": {
      "phone_number": "01012345678"
    },
    "note": "طلب سحب المستحقات عبر فودافون كاش",
    "is_approved": "pending",
    "created_at": "2026-09-08T15:00:00.000000Z"
  }
}
```

---

### 1.4 عرض الطلبات المعلقة (Get Pending Withdraw Requests)
- **Method:** `GET`
- **URL:** `{{base_url}}/api/driver/withdraw/pending-request?limit=10&offset=1`
- **Headers:**
  - `Authorization`: `Bearer {{driver_token}}`
  - `Accept`: `application/json`

#### Response (200 OK)
```json
{
  "response_code": "default_200",
  "message": "Pending withdrawal requests retrieved successfully",
  "content": [
    {
      "id": "req_w_987654",
      "amount": 500.00,
      "method_name": "Vodafone Cash",
      "phone_number": "01012345678",
      "is_approved": "pending",
      "created_at": "2026-09-08T15:00:00Z"
    }
  ]
}
```

---

### 1.5 الطلبات المستواة وإثبات التحويل (Get Settled Requests)
- **Method:** `GET`
- **URL:** `{{base_url}}/api/driver/withdraw/settled-request?limit=10&offset=1`
- **Headers:**
  - `Authorization`: `Bearer {{driver_token}}`
  - `Accept`: `application/json`

#### Response (200 OK)
```json
{
  "response_code": "default_200",
  "message": "Settled withdrawal requests retrieved successfully",
  "content": [
    {
      "id": "req_w_987654",
      "amount": 500.00,
      "transferred_amount": 500.00,
      "transfer_screenshot": "https://drivoeg.com/storage/withdrawals/transfer_receipt_987654.png",
      "approval_note": "تم التحويل بنجاح وإعادة تصفير الحساب",
      "is_approved": "settled",
      "updated_at": "2026-09-08T15:15:00Z"
    }
  ]
}
```

---

### 1.6 تعميد الطلب ورفع إثبات التحويل من الداشبورد (Approve & Settle Request)
- **Method:** `POST`
- **URL:** `{{base_url}}/admin/driver/withdraw/action`
- **Headers:**
  - `Accept`: `application/json`
- **Body Format:** `form-data`
  - `id`: `<WITHDRAW_REQUEST_ID>`
  - `status`: `settled`
  - `transferred_amount`: `500.00`
  - `approval_note`: `تم التحويل بنجاح وإعادة تصفير الحساب`
  - `transfer_screenshot`: `[ملف الصورة]`

#### Response (200 OK)
```json
{
  "response_code": "default_update_200",
  "message": "Withdrawal request approved and settled successfully",
  "content": {
    "id": "req_w_987654",
    "status": "settled",
    "transferred_amount": 500.00,
    "transfer_screenshot": "https://drivoeg.com/storage/withdrawals/transfer_receipt_987654.png",
    "approval_note": "تم التحويل بنجاح وإعادة تصفير الحساب"
  }
}
```

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

---

## 3. Driver School & University Routes

إدارة إنشاء خطوط سير الجامعات والمدارس من تطبيق السائق ومتابعة وتعميد طلبات اشتراك الطلاب والركاب.

### 3.1 إنشاء خط سير جامعة من تطبيق السائق (Create University Route)
- **Method:** `POST`
- **URL:** `{{base_url}}/api/driver/register-route`
- **Headers:**
  - `Authorization`: `Bearer {{driver_token}}`
  - `Content-Type`: `application/json`
  - `Accept`: `application/json`

#### Request Body
```json
{
    "carpool_type": "university",
    "route_name": "خط جامعة القاهرة - عباس العقاد",
    "start_address": "عباس العقاد - مدينة نصر",
    "end_address": "جامعة القاهرة - الجيزة",
    "start_lat": 30.0444,
    "start_lng": 31.2357,
    "end_lat": 30.0275,
    "end_lng": 31.2091,
    "start_time": "2026-09-10 07:30:00",
    "departure_time": "07:30",
    "return_time": "16:30",
    "price": 1500.00,
    "seats_available": 4,
    "allowed_gender": "both",
    "is_ac": true,
    "days_of_week": ["sunday", "monday", "tuesday", "wednesday", "thursday"],
    "rest_stops": [
        {"name": "مكرم عبيد", "lat": 30.0500, "lng": 31.2400},
        {"name": "ميدان رمسيس", "lat": 30.0600, "lng": 31.2450}
    ]
}
```

#### Response (200 OK)
```json
{
  "response_code": "default_store_200",
  "message": "University route created successfully",
  "content": {
    "id": 599,
    "user_id": "b9208668-9648-47d2-8d44-d3d411c7dbd3",
    "carpool_type": "university",
    "title": "خط جامعة القاهرة - عباس العقاد",
    "start_address": "عباس العقاد - مدينة نصر",
    "end_address": "جامعة القاهرة - الجيزة",
    "departure_time": "07:30",
    "return_time": "16:30",
    "price": 1500.00,
    "seats_available": 4,
    "status": "active",
    "created_at": "2026-09-08T15:00:00.000000Z"
  }
}
```

---

### 3.2 إنشاء خط سير مدرسة من تطبيق السائق (Create School Route)
- **Method:** `POST`
- **URL:** `{{base_url}}/api/driver/register-route`
- **Headers:**
  - `Authorization`: `Bearer {{driver_token}}`
  - `Content-Type`: `application/json`
  - `Accept`: `application/json`

#### Request Body
```json
{
    "carpool_type": "school",
    "route_name": "خط مدرسة التوفيقية - التجمع الخامس",
    "start_address": "شارع التسعين - التجمع الخامس",
    "end_address": "مدرسة التوفيقية - القاهرة",
    "start_lat": 30.0200,
    "start_lng": 31.4300,
    "end_lat": 30.0600,
    "end_lng": 31.3300,
    "start_time": "2026-09-10 06:45:00",
    "departure_time": "06:45",
    "return_time": "14:30",
    "price": 1800.00,
    "seats_available": 4,
    "allowed_gender": "both",
    "is_ac": true,
    "days_of_week": ["sunday", "monday", "tuesday", "wednesday", "thursday"],
    "rest_stops": [
        {"name": "الرحاب بوابة 6", "lat": 30.0600, "lng": 31.4800}
    ]
}
```

#### Response (200 OK)
```json
{
  "response_code": "default_store_200",
  "message": "School route created successfully",
  "content": {
    "id": 600,
    "user_id": "b9208668-9648-47d2-8d44-d3d411c7dbd3",
    "carpool_type": "school",
    "title": "خط مدرسة التوفيقية - التجمع الخامس",
    "start_address": "شارع التسعين - التجمع الخامس",
    "end_address": "مدرسة التوفيقية - القاهرة",
    "departure_time": "06:45",
    "return_time": "14:30",
    "price": 1800.00,
    "seats_available": 4,
    "status": "active",
    "created_at": "2026-09-08T15:05:00.000000Z"
  }
}
```

---

### 3.3 عرض الخطوط وطلبات الركاب القادمة (Get Driver Routes & Requests)
- **Method:** `GET`
- **URL:** `{{base_url}}/api/driver/carpool-routes`
- **Headers:**
  - `Authorization`: `Bearer {{driver_token}}`
  - `Accept`: `application/json`

#### Response (200 OK)
```json
{
  "response_code": "default_200",
  "message": "Driver carpool routes and passenger requests retrieved successfully",
  "content": [
    {
      "id": 599,
      "title": "خط جامعة القاهرة - عباس العقاد",
      "carpool_type": "university",
      "seats_available": 3,
      "price": 1500.00,
      "passengers": [
        {
          "id": "pass_123",
          "user_id": "cust_uuid_789",
          "user_name": "Omar Mahmoud",
          "user_phone": "+201099887766",
          "subscription_id": "sub_uni_4567",
          "subscription_duration": "monthly",
          "payment_method": "instapay",
          "receipt_image": "https://drivoeg.com/storage/receipts/receipt_uni_123.png",
          "payment_verification": "pending_verification",
          "driver_decision": "pending",
          "status": "pending"
        }
      ]
    }
  ]
}
```

---

### 3.4 قبول السائق لطلب الراكب (Accept Passenger Request)
- **Method:** `POST`
- **URL:** `{{base_url}}/api/driver/review`
- **Headers:**
  - `Authorization`: `Bearer {{driver_token}}`
  - `Content-Type`: `application/json`
  - `Accept`: `application/json`

#### Request Body
```json
{
    "carpool_passenger_id": "pass_123",
    "decision": "accept"
}
```

#### Response (200 OK)
```json
{
  "response_code": "default_update_200",
  "message": "Passenger request accepted successfully",
  "content": {
    "id": "pass_123",
    "driver_decision": "accepted",
    "status": "onboard"
  }
}
```

---

### 3.5 رفض السائق لطلب الراكب (Reject Passenger Request)
- **Method:** `POST`
- **URL:** `{{base_url}}/api/driver/review`
- **Headers:**
  - `Authorization`: `Bearer {{driver_token}}`
  - `Content-Type`: `application/json`
  - `Accept`: `application/json`

#### Request Body
```json
{
    "carpool_passenger_id": "pass_123",
    "decision": "reject"
}
```

#### Response (200 OK)
```json
{
  "response_code": "default_update_200",
  "message": "Passenger request rejected successfully",
  "content": {
    "id": "pass_123",
    "driver_decision": "rejected",
    "status": "cancelled"
  }
}
```

---

### 3.6 عرض قائمة الركاب المقبولين بالخط (Get Accepted Passengers)
- **Method:** `GET`
- **URL:** `{{base_url}}/api/driver/{{carpool_route_id}}/accepted-passengers`
- **Headers:**
  - `Authorization`: `Bearer {{driver_token}}`
  - `Accept`: `application/json`

#### Response (200 OK)
```json
{
  "response_code": "default_200",
  "message": "Accepted passengers retrieved successfully",
  "content": [
    {
      "id": "pass_123",
      "user_name": "Omar Mahmoud",
      "user_phone": "+201099887766",
      "gender": "male",
      "seats_count": 1,
      "subscription_duration": "monthly",
      "status": "onboard",
      "start_date": "2026-09-10",
      "end_date": "2026-10-10"
    }
  ]
}
```
