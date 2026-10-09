# Drivo App - University Trips Backend API Specification

This document details the REST API specifications, required endpoints, request payloads, response structures, authentication headers, and error codes for the **University Trips & Subscriptions** feature.

---

## 1. Authentication & Base Headers

All requests to these endpoints require a valid customer bearer token and localization headers:

```http
Authorization: Bearer {token}
Accept: application/json
Content-Type: application/json
X-localization: en (or ar)
zoneId: {zone_id}
```

---

## 2. API Endpoints Summary

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/customer/university/config` | Get list of supported universities & initial pickup locations | Yes |
| `POST` | `/api/customer/university/find-trips` | Search matching university trips based on search criteria | Yes |
| `GET` | `/api/customer/university/trips/{trip_id}` | Get full details for a specific university trip | Yes |
| `GET` | `/api/customer/university/trips/{trip_id}/pickup-points` | Get pickup stops along a trip's route for stop modification | Yes |
| `POST` | `/api/customer/university/subscribe` | Book/subscribe to a route with payment method & receipt upload | Yes (Multipart) |
| `GET` | `/api/customer/university/my-subscriptions` | Get user's active/past university trip subscriptions | Yes |
| `GET` | `/api/customer/university/active-trip` | Get current active/ongoing university trip details for the user | Yes |


---

## 3. Endpoints Detail

### 3.1. Get University Configuration
- **Route:** `GET /api/customer/university/config`
- **Description:** Returns the active universities and general pickup points/zones to populate dropdowns in the search screen.

#### Success Response (`200 OK`):
```json
{
  "response_code": "default_200",
  "message": "University config fetched successfully",
  "content": {
    "universities": [
      {
        "id": "uni_1",
        "name": "Cairo University",
        "name_ar": "جامعة القاهرة",
        "address": "Giza, Egypt",
        "latitude": 30.0263,
        "longitude": 31.2118,
        "main_gate": "Main Gate - Front of Clock"
      },
      {
        "id": "uni_2",
        "name": "Ain Shams University",
        "name_ar": "جامعة عين شمس",
        "address": "Abbassia, Cairo, Egypt",
        "latitude": 30.0771,
        "longitude": 31.2859,
        "main_gate": "Engineering Gate"
      },
      {
        "id": "uni_3",
        "name": "American University in Cairo (AUC)",
        "name_ar": "الجامعة الأمريكية بالقاهرة",
        "address": "New Cairo, Egypt",
        "latitude": 30.0194,
        "longitude": 31.4996,
        "main_gate": "Gate 1 - AUC Avenue"
      },
      {
        "id": "uni_4",
        "name": "German University in Cairo (GUC)",
        "name_ar": "الجامعة الألمانية بالقاهرة",
        "address": "New Cairo, Egypt",
        "latitude": 29.9869,
        "longitude": 31.4413,
        "main_gate": "Main Gate"
      }
    ],
    "pickup_points": [
      {
        "id": "point_1",
        "name": "Abbas El Akkad",
        "name_ar": "عباس العقاد",
        "area": "Nasr City",
        "latitude": 30.0601,
        "longitude": 31.3411
      },
      {
        "id": "point_2",
        "name": "Makram Ebeid",
        "name_ar": "مكرم عبيد",
        "area": "Nasr City",
        "latitude": 30.0543,
        "longitude": 31.3482
      },
      {
        "id": "point_3",
        "name": "Dokki",
        "name_ar": "الدقي",
        "area": "Giza",
        "latitude": 30.0385,
        "longitude": 31.2111
      },
      {
        "id": "point_4",
        "name": "Tagamoa (5th Settlement)",
        "name_ar": "التجمع الخامس",
        "area": "New Cairo",
        "latitude": 30.0210,
        "longitude": 31.4720
      }
    ]
  }
}
```

---

### 3.2. Find Matching University Trips
- **Route:** `POST /api/customer/university/find-trips`
- **Description:** Searches for matching university trips based on user criteria.

#### Request Body:
```json
{
  "university_id": "uni_1",
  "university_name": "Cairo University",
  "pickup_point_id": "point_1",
  "pickup_point_name": "Abbas El Akkad",
  "date": "2026-09-07",
  "seats": 1,
  "gender": "male",
  "need_return_ride": true
}
```

#### Field Specifications:
| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `university_id` | `string` | Optional | ID of the selected university |
| `university_name` | `string` | Required | Name/keyword of the university |
| `pickup_point_id` | `string` | Optional | ID of selected pickup point |
| `pickup_point_name` | `string` | Required | Name/keyword of pickup location |
| `date` | `string (YYYY-MM-DD)` | Required | Selected trip starting date |
| `seats` | `integer` | Required | Number of passenger seats (1 to 4) |
| `gender` | `string` | Required | Allowed passenger gender (`"male"`, `"female"`, `"any"`) |
| `need_return_ride` | `boolean` | Required | Whether a return trip from university is included |

#### Success Response (`200 OK`):
```json
{
  "response_code": "default_200",
  "message": "Matching trips found",
  "content": [
    {
      "id": "1",
      "route_name": "Route 5",
      "from_area": "Nasr City",
      "to_university": "Cairo University",
      "pickup_point": "Abbas El Akkad",
      "destination_point": "Cairo University Main Gate",
      "schedule_time": "7:00 AM",
      "return_time": "4:00 PM",
      "monthly_price": 1450.0,
      "weekly_price": 500.0,
      "seats_left": 6,
      "subscription_type": "Monthly · 30 days",
      "valid_until": "Sep 30, 2026",
      "has_return_ride": true,
      "driver": {
        "id": "drv_1",
        "name": "Ahmed Samir",
        "phone": "+201012345678",
        "vehicle": "Toyota Hiace",
        "plate_number": "ق ط ر 567",
        "rating": 4.9,
        "avatar": "https://drivoeg.com/storage/profile/driver1.png"
      }
    },
    {
      "id": "2",
      "route_name": "Route 8",
      "from_area": "Heliopolis",
      "to_university": "Cairo University",
      "pickup_point": "Abbas El Akkad",
      "destination_point": "Cairo University Engineering Gate",
      "schedule_time": "7:20 AM",
      "return_time": "4:30 PM",
      "monthly_price": 1350.0,
      "weekly_price": 475.0,
      "seats_left": 3,
      "subscription_type": "Monthly · 30 days",
      "valid_until": "Sep 30, 2026",
      "has_return_ride": true,
      "driver": {
        "id": "drv_2",
        "name": "Mohamed Ali",
        "phone": "+201198765432",
        "vehicle": "Toyota Coaster",
        "plate_number": "س م ع 892",
        "rating": 4.8,
        "avatar": "https://drivoeg.com/storage/profile/driver2.png"
      }
    }
  ]
}
```

---

### 3.3. Get Pickup Points For Trip Route
- **Route:** `GET /api/customer/university/trips/{trip_id}/pickup-points`
- **Description:** Returns the ordered pickup points along the route of a trip, showing timings and distances.

#### Success Response (`200 OK`):
```json
{
  "response_code": "default_200",
  "message": "Pickup points fetched successfully",
  "content": [
    {
      "id": "pt_1",
      "name": "Nasr City Club",
      "timing": "Pickup 7:15 AM · 0.8 km away",
      "tag": "Current pickup point",
      "latitude": 30.0612,
      "longitude": 31.3389
    },
    {
      "id": "pt_2",
      "name": "Abbas El Akkad",
      "timing": "Pickup 7:25 AM · 1.4 km away",
      "tag": "",
      "latitude": 30.0601,
      "longitude": 31.3411
    },
    {
      "id": "pt_3",
      "name": "Makram Ebeid",
      "timing": "Pickup 7:35 AM · 2.1 km away",
      "tag": "",
      "latitude": 30.0543,
      "longitude": 31.3482
    }
  ]
}
```

---

### 3.4. Subscribe / Book University Trip (With Receipt Upload)
- **Route:** `POST /api/customer/university/subscribe`
- **Content-Type:** `multipart/form-data`
- **Description:** Submits a subscription request. If payment method is InstaPay or Vodafone Cash, an uploaded receipt image file is attached.

#### Multipart Form Fields:
| Field Name | Type | Required | Description / Example |
| :--- | :--- | :--- | :--- |
| `trip_id` | `string` | Required | `"1"` |
| `pickup_point` | `string` | Required | `"Abbas El Akkad"` |
| `pickup_point_id` | `string` | Optional | `"pt_2"` |
| `subscription_duration` | `string` | Required | `"monthly"` or `"weekly"` |
| `payment_method` | `string` | Required | `"instapay"` \| `"vodafone_cash"` \| `"wallet"` \| `"card"` |
| `seats` | `integer` | Required | `1` |
| `gender` | `string` | Required | `"male"` \| `"female"` |
| `need_return_ride` | `integer (0 or 1)` | Required | `1` |
| `amount` | `float` | Required | `1450.00` |
| `receipt_image` | `File (image/jpeg, image/png)` | Conditional | Uploaded receipt screenshot (required for InstaPay / Vodafone Cash) |

#### Success Response (`200 OK`):
```json
{
  "response_code": "default_200",
  "message": "Subscription submitted successfully. Verification in progress.",
  "content": {
    "subscription_id": "SUB-2026-9871",
    "trip_id": "1",
    "route_name": "Route 5",
    "university": "Cairo University",
    "pickup_point": "Abbas El Akkad",
    "subscription_duration": "monthly",
    "start_date": "2026-09-07",
    "end_date": "2026-10-07",
    "status": "pending_verification",
    "payment_method": "instapay",
    "payment_status": "pending_review",
    "amount": 1450.0,
    "receipt_url": "https://drivoeg.com/storage/receipts/receipt_9871.jpg",
    "created_at": "2026-09-07T12:00:00.000000Z"
  }
}
```

---

### 3.5. Get User's University Subscriptions
- **Route:** `GET /api/customer/university/my-subscriptions`
- **Description:** Returns active and past university subscriptions of the logged-in customer.

#### Success Response (`200 OK`):
```json
{
  "response_code": "default_200",
  "message": "Subscriptions list fetched successfully",
  "content": [
    {
      "subscription_id": "SUB-2026-9871",
      "trip_id": "1",
      "route_name": "Route 5",
      "university": "Cairo University",
      "pickup_point": "Abbas El Akkad",
      "subscription_duration": "monthly",
      "status": "active",
      "start_date": "2026-09-07",
      "end_date": "2026-10-07",
      "has_return_ride": true,
      "amount": 1450.0,
      "driver": {
        "name": "Ahmed Samir",
        "phone": "+201012345678",
        "vehicle": "Toyota Hiace",
        "rating": 4.9
      }
    }
  ]
}
```

---

### 3.6. Get Active / Ongoing University Trip
- **Route:** `GET /api/customer/university/active-trip`
- **Description:** Returns the active ongoing university subscription/trip details for the user to show on the search screen banner and ongoing trip live tracking page.
- **Headers:** `Authorization: Bearer {token}`

#### Success Response (`200 OK`):
```json
{
  "response_code": "default_200",
  "message": "Active university trip retrieved successfully",
  "content": {
    "id": "trip_act_101",
    "route_name": "Route 5",
    "university_name": "Cairo University",
    "pickup_point": "Abbas El Akkad",
    "pickup_address": "Madinat Al-Amal, Nasr City",
    "destination_address": "Downtown Cairo",
    "pickup_time": "7:00 AM",
    "departure_time": "07:30 AM",
    "estimated_arrival": "08:25 AM",
    "subscription_type": "Monthly",
    "valid_until": "Sep 30",
    "has_return_ride": true,
    "status": "on_route",
    "status_text": "On route",
    "seat_label": "Seat 2 of 4",
    "route_subtitle": "Route to Downtown",
    "pickup_eta_minutes": 8,
    "driver": {
      "id": "drv_10",
      "name": "Karim Fathy",
      "phone": "+201099887766",
      "vehicle_name": "Kia Cerato",
      "vehicle_color": "White",
      "plate_number": "CAI 2290",
      "rating": 4.9,
      "is_verified": true,
      "avatar_initial": "K",
      "eta_minutes": 6
    },
    "driver_latitude": 30.0528,
    "driver_longitude": 31.2915,
    "pickup_latitude": 30.0601,
    "pickup_longitude": 31.3411,
    "destination_latitude": 30.0444,
    "destination_longitude": 31.2357,
    "start_trip_code": "4829",
    "passengers": [
      {
        "name": "Sarah",
        "avatar_initial": "S"
      },
      {
        "name": "Nour",
        "avatar_initial": "N"
      }
    ],
    "additional_passengers_count": 1,
    "total_passengers_text": "3 passengers sharing this route"
  }
}
```

---

## 4. Error Responses


Standard Drivo API error envelope:

```json
{
  "response_code": "error_422",
  "message": "Validation error",
  "errors": [
    {
      "error_code": "receipt_image",
      "message": "The receipt image is required when paying via InstaPay."
    }
  ]
}
```
