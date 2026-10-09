# توثيق الـ Endpoint الخاصة بـ "الرحلات القريبة مني" (Carpool Near Me API)

وثيقة الشرح الكاملة والمفصلة الخاصة بالـ Endpoint الجديدة للركاب/العملاء (`near-me`) لرحلات الكاربول (Carpool Routes)، وتوضيح البرامترات المطلوبة، المنطق البرمجي، وشكل الـ Response المتوقع.

---

## 1. المقدمة والهدف (Overview)

تم إنشاء الـ Endpoint باسم `near-me` لتسمح للعميل/الراكب بالبحث عن جميع رحلات الـ Carpool (سواء رحلات فردية، سفر بين المحافظات، روتين، الساحل، مدارس أو جامعات) القريبة من موقعه الجغرافي الحالي.

يقوم السيرفر بحساب المسافة الجغرافية (باستخدام معادلة Haversine) بين إحداثيات موقع الراكب المرسلة في الطلب وبين **جميع نقاط خط سير كل رحلة** (بما في ذلك نقطة البداية، النهاية، النقاط المحفوظة على المسار، النقاط المفككة من الـ polyline، المحطات `boarding_points` والمستراحات)، وترتيب الرحلات المتاحة تنازلياً من **الأقرب مسافة إلى الأبعد**.

---

## 2. تفاصيل الـ Endpoint (API Specification)

- **HTTP Method:** `POST` *(ويدعم أيضاً `GET` في حال تمريرا البيانات عبر Query Parameters)*
- **URL Base:** `{{base_url}}/api/customer/carpool/near-me`
- **مسارات إضافية مدعومة:**
  - `POST /api/customer/near-me`
  - `POST /api/passenger/near-me`
  - `GET /api/customer/carpool/near-me`

### Headers المطلوبة
| Header Name | Value | الوصف |
| :--- | :--- | :--- |
| `Authorization` | `Bearer {{customer_token}}` | توكن تسجيل دخول العميل (مطلوب) |
| `Content-Type` | `application/json` | نوع البيانات المرسلة |
| `Accept` | `application/json` | استلام النتيجة بصيغة JSON |

---

## 3. متغيرات الطلب (Request Parameters)

تمت إضافة خاصية **المرونة والتعامل مع مرادفات الأسماء (Parameter Aliasing)**، بحيث يمكن للتطبيق إرسال الأسماء التالية وسيقبلها السيرفر دون مشاكل:

| اسم البرامتر الأصلي | المرادفات المقبولة (Aliases) | النوع (Data Type) | الحالة | الوصف والاختيارات |
| :--- | :--- | :--- | :--- | :--- |
| `latitude` | `lat` | `numeric` | **مطلوب** | خط العرض لموقع الراكب (بين -90 و 90) |
| `longitude` | `long`, `lng` | `numeric` | **مطلوب** | خط الطول لموقع الراكب (بين -180 و 180) |
| `radius` | `distance` | `numeric` | اختياري | نصف قطر البحث بالكيلومترات (الافتراضي: **10 كم**) |
| `day` | `date` | `date` | اختياري | تاريخ البحث بتنسيق `YYYY-MM-DD` (الافتراضي: اليوم الحالي) |
| `carpool_type` | - | `string` | اختياري | نوع الرحلة: `one_trip`, `travel`, `routine`, `north_coast`, `school`, `university` |
| `gender` | - | `string` | اختياري | جنس السائق/الرحلة المسموح: `male`, `female`, `both` |
| `seats_required` | - | `integer` | اختياري | عدد المقاعد المطلوبة للراكب (الافتراضي: `1`) |
| `limit` | - | `integer` | اختياري | عدد النتائج في الصفحة الواحدة (الافتراضي: `20` الحد الأقصى: `100`) |
| `offset` | - | `integer` | اختياري | رقم الترحيل لصفحات النتائج (الافتراضي: `0`) |

---

## 4. مثال على الـ Request Body

```json
{
    "lat": 30.0444,
    "long": 31.2357,
    "radius": 15,
    "day": "2026-09-09",
    "seats_required": 1,
    "limit": 20,
    "offset": 0
}
```

---

## 5. شكل الـ Response المتوقع (JSON Response Structure)

### 5.1 استجابة ناجحة (200 OK)

```json
{
    "response_code": "default_200",
    "message": "successfully_loaded",
    "content": {
        "section": {
            "title": "Nearby Carpool Routes",
            "title_ar": "رحلات الكاربول القريبة منك",
            "user_location": {
                "lat": 30.0444,
                "lng": 31.2357
            },
            "search_radius_km": 15,
            "date": "2026-09-09"
        },
        "total": 2,
        "limit": 20,
        "offset": 0,
        "trips": [
            {
                "route_id": 15,
                "title": "رحلة التجمع - المعادي",
                "start_date": "2026-09-09",
                "end_date": null,
                "carpool_type": "routine",
                "carpool_type_label": "Routine",
                "carpool_type_label_ar": "روتين",
                "distance_from_user_km": 1.85,
                "closest_point": {
                    "lat": 30.0452,
                    "lng": 31.2368
                },
                "driver": {
                    "id": "c71a3962-9759-4fa2-a279-7988582f34bb",
                    "full_name": "أحمد محمود",
                    "gender": "male",
                    "profile_image": "http://drivoeg.com/storage/app/public/driver/profile/profile.png",
                    "phone": "+201012345678"
                },
                "vehicle": {
                    "id": 8,
                    "category_id": "c12a839f-298a",
                    "brand": "Toyota",
                    "model": "Corolla",
                    "plate_number": "أ ب ج 1234"
                },
                "start_time": "2026-09-09 08:30:00",
                "start_address": "شارع 9 المعادي",
                "end_address": "التجمع الخامس - شارع التسعين",
                "start_location": {
                    "lat": 29.9602,
                    "lng": 31.2569
                },
                "end_location": {
                    "lat": 30.0271,
                    "lng": 31.4394
                },
                "seats_available": 3,
                "price": 75.0,
                "daily_price_per_seat": 75.0,
                "departure_time": "08:30",
                "return_time": "17:00",
                "boarding_point_start": null,
                "boarding_point_end": null,
                "is_ac": true,
                "is_smoking_allowed": false,
                "has_music": true,
                "has_screen_entertainment": false,
                "allow_luggage": true,
                "allowed_gender": "both",
                "allowed_age_min": 18,
                "allowed_age_max": 60,
                "encoded_polyline": "a~_~F|~_~O...",
                "is_recurring": true,
                "recurring_info": {
                    "recurrence_type": "repeated",
                    "selected_dates": [
                        "2026-09-09",
                        "2026-09-10",
                        "2026-09-11"
                    ],
                    "available_dates": [
                        "2026-09-09",
                        "2026-09-10",
                        "2026-09-11"
                    ]
                }
            },
            {
                "route_id": 22,
                "title": "سفر القاهرة - الإسكندرية",
                "start_date": "2026-09-09",
                "end_date": "2026-09-09",
                "carpool_type": "travel",
                "carpool_type_label": "Travel",
                "carpool_type_label_ar": "سفر",
                "distance_from_user_km": 4.12,
                "closest_point": {
                    "lat": 30.0510,
                    "lng": 31.2401
                },
                "driver": {
                    "id": "e93108ab-9831-419b-b612-4011285bc012",
                    "full_name": "محمد السيد",
                    "gender": "male",
                    "profile_image": "http://drivoeg.com/storage/app/public/driver/profile/profile2.png",
                    "phone": "+201198765432"
                },
                "vehicle": {
                    "id": 12,
                    "category_id": "c12a839f-298a",
                    "brand": "Hyundai",
                    "model": "Elantra",
                    "plate_number": "س ص ع 5678"
                },
                "start_time": "2026-09-09 14:00:00",
                "start_address": "ميدان رمسيس",
                "end_address": "محطة سيدي جابر - الإسكندرية",
                "start_location": {
                    "lat": 30.0617,
                    "lng": 31.2464
                },
                "end_location": {
                    "lat": 31.2185,
                    "lng": 29.9431
                },
                "seats_available": 2,
                "price": 200.0,
                "daily_price_per_seat": 200.0,
                "departure_time": "14:00",
                "return_time": null,
                "boarding_point_start": {
                    "id": 1,
                    "name": "ميدان رمسيس"
                },
                "boarding_point_end": {
                    "id": 5,
                    "name": "سيدي جابر"
                },
                "is_ac": true,
                "is_smoking_allowed": false,
                "has_music": false,
                "has_screen_entertainment": true,
                "allow_luggage": true,
                "allowed_gender": "both",
                "allowed_age_min": 15,
                "allowed_age_max": 70,
                "encoded_polyline": "c{_~Fv~_~O...",
                "is_recurring": false,
                "recurring_info": null
            }
        ]
    }
}
```

---

## 6. استجابات الأخطاء والمتوقعة (Error Handling)

### 6.1 خطأ في البيانات المدخلة (403 Bad Request / Validation Error)
يحدث عند عدم إرسال خطوط العرض وخطوط الطول، أو إرسال قيم غير رقمية:

```json
{
    "response_code": "default_400",
    "message": "validation_failed",
    "errors": [
        {
            "attribute": "latitude",
            "message": "The latitude field is required."
        },
        {
            "attribute": "longitude",
            "message": "The longitude field is required."
        }
    ]
}
```

### 6.2 خطأ في التوكن / المصادقة (401 Unauthorized)
يحدث عند عدم إرسال `Authorization Bearer Header` أو عند انتهاء صلاحية التوكن:

```json
{
    "message": "Unauthenticated."
}
```

---

## 7. شرح الحقول في الاستجابة (Field Descriptions)

- **`distance_from_user_km`**: أقرب مسافة بالكيلومتر بين موقع العميل المرسل وأي نقطة يمر بها مسار هذه الرحلة.
- **`closest_point`**: إحداثيات `lat` و `lng` لأقرب نقطة على مسار الرحلة من الراكب.
- **`seats_available`**: عدد المقاعد المتبقية المتاحة للحجز في هذه الرحلة في اليوم المطلوب.
- **`carpool_type`**: نوع الرحلة الفعلي، و`carpool_type_label_ar` هو الاسم المترجم الموجه للواجهة العربية.
- **`driver`**: بيانات السائق (الاسم الكامل، الصورة، رقم الهاتف، الجنس).
- **`vehicle`**: بيانات السيارة (الماركة، الموديل، الفئة، رقم اللوحة).
- **`encoded_polyline`**: المسار المشفر بخريطة جوجل لكي يتم رسم الخط الجغرافي على الخريطة في تطبيق العميل.
