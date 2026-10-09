# Drivo School Carpool Feature - Backend API Specification

This document provides the complete API specification for the **School Carpool** feature in the Drivo User app. The backend team should implement these endpoints to fully support the client application flows, matching the Figma design and business logic.

---

## Table of Contents

1. [General Specifications](#1-general-specifications)
2. [Endpoints Overview](#2-endpoints-overview)
3. [Endpoint Details](#3-endpoint-details)
   - [3.1. Get School Configuration & Pickups](#31-get-school-configuration--pickups)
   - [3.2. Find Matching School Trips](#32-find-matching-school-trips)
   - [3.3. Get School Trip Details](#33-get-school-trip-details)
   - [3.4. Get Pickup Points for a Trip](#34-get-pickup-points-for-a-trip)
   - [3.5. Subscribe to a School Trip (Booking & Payment)](#35-subscribe-to-a-school-trip-booking--payment)
   - [3.6. Get My School Subscriptions](#36-get-my-school-subscriptions)
   - [3.7. Get Active / Ongoing School Trip](#37-get-active--ongoing-school-trip)
4. [Data Models & Enums](#4-data-models--enums)
5. [Error Handling](#5-error-handling)

---

## 1. General Specifications

- **Base URL**: `https://<domain>/api/customer/school`
- **Protocol**: HTTPS
- **Content-Type**: `application/json` (except multipart for file uploads)
- **Authentication**: Bearer Token in `Authorization` header
- **Localization**: Handled via `X-Localization` header (`en` or `ar`)

### Common Headers

```http
Authorization: Bearer <user_jwt_token>
X-Localization: en
Accept: application/json
```

---

## 2. Endpoints Overview

| Method | Endpoint | Description | Figma Screen |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/customer/school/config` | Retrieves available schools and pickup points list | Screen 1 (Search School Trips) |
| `POST` | `/api/customer/school/find-trips` | Searches for matching school trips based on filters | Screen 2 & 3 (Matching Trips / Empty State) |
| `GET` | `/api/customer/school/trips/{trip_id}` | Retrieves full trip details by ID | Screen 4 (School Trip Details) |
| `GET` | `/api/customer/school/trips/{trip_id}/pickup-points` | Retrieves available quick pickup points assigned to route | Screen 5 (Change Pickup Point) |
| `POST` | `/api/customer/school/subscribe` | Books and submits payment receipt for subscription | Screen 3 (Payment & Activation) |
| `GET` | `/api/customer/school/my-subscriptions` | Retrieves list of user's past and active subscriptions | Profile / Subscriptions list |
| `GET` | `/api/customer/school/active-trip` | Retrieves user's currently active/ongoing school trip | Screen 1 (Top Card) & Screen 6 (Ongoing Trip Live Map) |

---

## 3. Endpoint Details

### 3.1. Get School Configuration & Pickups

- **Endpoint**: `GET /api/customer/school/config`
- **Description**: Returns all supported schools and their associated pickup points for dropdown selectors on the Search screen.

#### Request Headers

```http
Authorization: Bearer <token>
X-Localization: en
```

#### Success Response (`200 OK`)

```json
{
  "response_code": "default_200",
  "message": "School configuration retrieved successfully",
  "content": {
    "schools": [
      {
        "id": "sch_1",
        "name": "Cairo school",
        "name_ar": "مدرسة القاهرة",
        "address": "Nasr City, Cairo",
        "latitude": 30.0588,
        "longitude": 31.3411,
        "main_gate": "Cairo school Main Gate",
        "pickup_points": [
          {
            "id": "p_1",
            "name": "Abbas El Akkad",
            "name_ar": "عباس العقاد",
            "school_id": "sch_1",
            "pickup_time": "7:25 AM",
            "distance_km": 1.4,
            "latitude": 30.0588,
            "longitude": 31.3411
          },
          {
            "id": "p_2",
            "name": "Nasr City Club",
            "name_ar": "نادي مدينة نصر",
            "school_id": "sch_1",
            "pickup_time": "7:15 AM",
            "distance_km": 0.9,
            "latitude": 30.0532,
            "longitude": 31.3325
          },
          {
            "id": "p_3",
            "name": "Makram Ebeid",
            "name_ar": "مكرم عبيد",
            "school_id": "sch_1",
            "pickup_time": "7:35 AM",
            "distance_km": 2.1,
            "latitude": 30.0612,
            "longitude": 31.3498
          }
        ]
      },
      {
        "id": "sch_2",
        "name": "New Cairo British School",
        "name_ar": "المدرسة البريطانية بالتجمع",
        "address": "New Cairo, 5th Settlement",
        "latitude": 30.0271,
        "longitude": 31.4721,
        "main_gate": "Gate 2 (Students Gate)",
        "pickup_points": []
      }
    ]
  }
}
```

---

### 3.2. Find Matching School Trips

- **Endpoint**: `POST /api/customer/school/find-trips`
- **Description**: Searches for scheduled carpool routes matching selected school, pickup point, date, seats count, gender preference, and return ride option.

#### Request Body

```json
{
  "school_name": "Cairo school",
  "pickup_point_name": "Abbas El Akkad",
  "school_id": "sch_1",
  "pickup_point_id": "p_1",
  "date": "2026-09-07",
  "seats": 1,
  "gender": "male",
  "need_return_ride": true
}
```

#### Success Response (`200 OK` - Trips Found)

```json
{
  "response_code": "default_200",
  "message": "Matching school trips found",
  "content": [
    {
      "id": "trip_sch_1",
      "route_name": "Route name",
      "from_area": "Nasr City",
      "to_school": "Cairo school",
      "pickup_point": "Abbas El Akkad",
      "destination": "Cairo school Main Gate",
      "schedule_time": "7:00 AM",
      "return_time": "7:00 PM",
      "departure_time": "7:00 AM",
      "price": 1450.00,
      "seats_left": 6,
      "has_return": true,
      "subscription_type": "monthly",
      "subscription_duration_days": 30,
      "valid_until": "Sep 30, 2026",
      "driver": {
        "name": "Ahmed Samir",
        "avatar": "A",
        "vehicle": "Toyota HiAce",
        "rating": 4.9
      }
    },
    {
      "id": "trip_sch_2",
      "route_name": "Route name",
      "from_area": "Heliopolis",
      "to_school": "Cairo school",
      "pickup_point": "Abbas El Akkad",
      "destination": "Cairo school Main Gate",
      "schedule_time": "7:20 AM",
      "return_time": "",
      "departure_time": "7:20 AM",
      "price": 1350.00,
      "seats_left": 3,
      "has_return": false,
      "subscription_type": "monthly",
      "subscription_duration_days": 30,
      "valid_until": "Sep 30, 2026",
      "driver": {
        "name": "Mahmoud Hassan",
        "avatar": "M",
        "vehicle": "Toyota Coaster",
        "rating": 4.8
      }
    }
  ]
}
```

#### Success Response (`200 OK` - Empty Results State - Figma Image 2)

```json
{
  "response_code": "default_200",
  "message": "No matching school trips found",
  "content": []
}
```

---

### 3.3. Get School Trip Details

- **Endpoint**: `GET /api/customer/school/trips/{trip_id}`
- **Description**: Returns detailed route, schedule, driver, pricing, and subscription breakdown for a single selected trip.

#### Response (`200 OK`)

```json
{
  "response_code": "default_200",
  "message": "Trip details retrieved successfully",
  "content": {
    "id": "trip_sch_1",
    "route_name": "Route name",
    "from_area": "Nasr City",
    "to_school": "Cairo school",
    "pickup_point": "Abbas El Akkad",
    "destination": "Cairo school Main Gate",
    "schedule_time": "7:00 AM",
    "return_time": "4:00 PM",
    "departure_time": "7:00 AM",
    "price": 1450.00,
    "seats_left": 6,
    "has_return": true,
    "subscription_type": "monthly",
    "subscription_duration_days": 30,
    "valid_until": "Sep 30, 2026",
    "driver": {
      "name": "Ahmed Samir",
      "avatar": "A",
      "vehicle": "Toyota HiAce",
      "rating": 4.9,
      "phone": "+201001234567"
    }
  }
}
```

---

### 3.4. Get Pickup Points for a Trip

- **Endpoint**: `GET /api/customer/school/trips/{trip_id}/pickup-points`
- **Description**: Returns available pickup locations assigned to this specific route so that the user can switch their pickup point without changing the route, driver, or destination (Figma Image 1, Screen 5).

#### Response (`200 OK`)

```json
{
  "response_code": "default_200",
  "message": "Pickup points retrieved successfully",
  "content": [
    {
      "id": "p_2",
      "name": "Nasr City Club",
      "name_ar": "نادي مدينة نصر",
      "pickup_time": "7:15 AM",
      "distance_text": "0.9 km away",
      "is_current": true,
      "latitude": 30.0532,
      "longitude": 31.3325
    },
    {
      "id": "p_1",
      "name": "Abbas El Akkad",
      "name_ar": "عباس العقاد",
      "pickup_time": "7:25 AM",
      "distance_text": "1.4 km away",
      "is_current": false,
      "latitude": 30.0588,
      "longitude": 31.3411
    },
    {
      "id": "p_3",
      "name": "Makram Ebeid",
      "name_ar": "مكرم عبيد",
      "pickup_time": "7:35 AM",
      "distance_text": "2.1 km away",
      "is_current": false,
      "latitude": 30.0612,
      "longitude": 31.3498
    }
  ]
}
```

---

### 3.5. Subscribe to a School Trip (Booking & Payment)

- **Endpoint**: `POST /api/customer/school/subscribe`
- **Description**: Submits the subscription booking with selected duration (`monthly` or `weekly`), payment method (`instapay` or `card`), and the payment screenshot receipt file.
- **Content-Type**: `multipart/form-data`

#### Form Fields

| Field Name | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `trip_id` | String | Yes | ID of the school trip |
| `pickup_point` | String | Yes | Selected pickup point name |
| `pickup_point_id` | String | No | Pickup point unique ID |
| `subscription_duration` | String | Yes | `monthly` (30 days) or `weekly` (15 days) |
| `payment_method` | String | Yes | `instapay` or `card` |
| `amount` | Number | Yes | Total calculated price (e.g. `1450.00` or `850.00`) |
| `seats` | Integer | Yes | Number of seats booked (default `1`) |
| `gender` | String | Yes | `male`, `female`, or `both` |
| `need_return_ride` | String/Bool | Yes | `'1'` if return ride included, `'0'` otherwise |
| `receipt_image` | Binary File | Yes (if instapay) | Screenshot of InstaPay transaction receipt |
| `note` | String | No | Optional remarks or student name/grade |

#### Success Response (`200 OK`)

```json
{
  "response_code": "default_200",
  "message": "Subscription request submitted successfully. Awaiting verification.",
  "content": {
    "subscription_id": "sub_sch_9901",
    "trip_id": "trip_sch_1",
    "status": "pending_verification",
    "start_date": "2026-09-08",
    "end_date": "2026-10-08",
    "amount": 1450.00,
    "payment_method": "instapay",
    "receipt_url": "https://cdn.drivo.app/receipts/sch_receipt_9901.jpg"
  }
}
```

---

### 3.6. Get My School Subscriptions

- **Endpoint**: `GET /api/customer/school/my-subscriptions`
- **Description**: Lists all active, pending, and past subscriptions for the authenticated student/parent.

#### Response (`200 OK`)

```json
{
  "response_code": "default_200",
  "message": "Subscriptions retrieved successfully",
  "content": [
    {
      "subscription_id": "sub_sch_9901",
      "trip_id": "trip_sch_1",
      "route_name": "Route name",
      "school": "Cairo school",
      "pickup_point": "Abbas El Akkad",
      "subscription_duration": "monthly",
      "status": "active",
      "start_date": "2026-09-08",
      "end_date": "2026-10-08",
      "has_return_ride": true,
      "amount": 1450.00,
      "driver": {
        "name": "Ahmed Samir",
        "phone": "+201001234567",
        "vehicle": "Toyota HiAce",
        "rating": 4.9
      }
    }
  ]
}
```

---

### 3.7. Get Active / Ongoing School Trip

- **Endpoint**: `GET /api/customer/school/active-trip`
- **Description**: Returns the active ongoing school trip for today. If the trip is on the way (`status: on_route`), this endpoint returns live driver coordinates, vehicle proximity, estimated arrival times, and passenger list (Figma Image 4, Screen 2).

#### Response (`200 OK` - Active Trip In Progress)

```json
{
  "response_code": "default_200",
  "message": "Active school trip retrieved successfully",
  "content": {
    "id": "active_sch_1",
    "route_name": "Route name",
    "school_name": "Cairo school",
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
    "start_trip_code": "4821",
    "total_passengers_text": "3 passengers sharing this route",
    "additional_passengers_count": 1,
    "pickup_latitude": 30.0601,
    "pickup_longitude": 31.3411,
    "destination_latitude": 30.0444,
    "destination_longitude": 31.2357,
    "driver_latitude": 30.0545,
    "driver_longitude": 31.3310,
    "driver": {
      "name": "Karim Fathy",
      "avatar": "K",
      "phone": "+201001234567",
      "vehicle_model": "Kia Cerato",
      "vehicle_color": "White",
      "plate_number": "CAI 2290",
      "rating": 4.9,
      "is_verified": true,
      "driver_eta_minutes": 6
    },
    "passengers": [
      {
        "name": "Sara",
        "avatar_text": "S"
      },
      {
        "name": "Nour",
        "avatar_text": "N"
      },
      {
        "name": "Omar",
        "avatar_text": "+1"
      }
    ]
  }
}
```

#### Response (`200 OK` - No Active Trip)

```json
{
  "response_code": "default_200",
  "message": "No active school trip",
  "content": null
}
```

---

## 4. Data Models & Enums

### Subscription Duration

- `monthly`: 30 calendar days (standard school month)
- `weekly`: 15 days (half month / bi-weekly package)

### Trip Status

- `scheduled`: Ride is upcoming for today
- `on_route`: Driver is currently en route to pickup point
- `started`: Passenger boarded and trip is ongoing
- `completed`: Trip finished
- `cancelled`: Trip cancelled

### Gender Filter

- `male`: Male only van
- `female`: Female only van
- `both`: Mixed passengers

---

## 5. Error Handling

All error responses return a uniform JSON format:

```json
{
  "response_code": "validation_422",
  "message": "The selected pickup point is outside the route boundaries",
  "errors": [
    {
      "field": "pickup_point_id",
      "message": "pickup_point_id does not belong to route trip_sch_1"
    }
  ]
}
```

### Standard Status Codes

- `200 OK`: Request succeeded.
- `400 Bad Request`: Missing or malformed parameters.
- `401 Unauthorized`: Token missing or expired.
- `404 Not Found`: Trip, school, or pickup point not found.
- `422 Unprocessable Entity`: Validation failure (e.g. no seats left, invalid receipt format).
- `500 Internal Server Error`: Server exception.
