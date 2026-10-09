# Customer ↔ Admin Chat API

Support chat between **customer (user)** and **admin** (same channel system as driver ↔ admin).

**Auth:** Bearer token (`auth:api`)  
**Base URL:** `https://drivoeg.com` (or your local host)

---

## Config

### `GET /api/customer/configuration`

Relevant fields added:

| Field | Type | Description |
| -------- | ------ | ------------- |
| `chatting_setup_status` | bool | Support chat enabled |
| `customer_question_answer_status` | bool | Predefined Q&A (if configured) |

---

## Customer endpoints (mobile)

All under prefix: `/api/customer/chat`  
Header: `Authorization: Bearer {customer_token}`

### 1. Create / open channel with admin

- **Method:** `PUT`
- **URL:** `/api/customer/chat/create-channel-with-admin`
- **Body:** none required (or empty JSON `{}`)

**Success response (existing channel):**

```json
{
  "response_code": "default_200",
  "message": "Successfully loaded",
  "data": {
    "user": {
      "id": "super-admin-uuid",
      "first_name": "Admin",
      "last_name": "User",
      "user_type": "super-admin",
      "phone": "+2001...",
      "profile_image": "..."
    },
    "channel": {
      "id": "channel-uuid-here",
      "trip_id": null,
      "updated_at": "2026-08-10T12:00:00.000000Z",
      "channel_users": [],
      "last_channel_conversations": null
    }
  }
}
```

Use `data.channel.id` as `channel_id` for the next calls.

---

### 2. Send message to admin

- **Method:** `PUT`
- **URL:** `/api/customer/chat/send-message-to-admin`
- **Content-Type:** `multipart/form-data` (or JSON if no files)

| Field | Required | Type | Description |
| -------- | ---------- | ------ | ------------- |
| `channel_id` | yes | string (UUID) | From create-channel |
| `message` | yes* | string | Text message (*or send files) |
| `files[]` | no | file | Optional attachments |

**Example form body:**

```
channel_id: a1b2c3d4-e5f6-7890-abcd-ef1234567890
message: مرحبا، محتاج مساعدة في حجزي
```

**Success:**

```json
{
  "response_code": "default_store_200",
  "message": "Successfully added",
  "data": null
}
```

Creates an admin notification (`new_message_arrived`) so admin sees it in the chatting page / notifications.

---

### 3. Send predefined question

- **Method:** `PUT`
- **URL:** `/api/customer/chat/send-predefined-question-to-admin`

| Field | Required | Description |
| -------- | ---------- | ------------- |
| `channel_id` | yes | Channel UUID |
| `question_id` | yes | Predefined Q&A id |

Writes the question as customer message and the answer as admin message.

---

### 4. Get conversation

- **Method:** `GET`
- **URL:** `/api/customer/chat/conversation`

| Query | Required | Description |
| -------- | ---------- | ------------- |
| `channel_id` | yes | Channel UUID |
| `limit` | no | Page size |
| `offset` | no | Offset |

**Example:**  
`GET /api/customer/chat/conversation?channel_id=a1b2c3d4-e5f6-7890-abcd-ef1234567890&limit=20&offset=0`

**Response `data`:** array of messages (`id`, `message`, `user`, `conversation_files`, timestamps, …).

---

### 5. Channel list

- **Method:** `GET`
- **URL:** `/api/customer/chat/channel-list`

Returns channels where the logged-in customer is a participant (includes support channel with admin).

---

### Related ride chat (customer ↔ driver on a trip)

Not the same as support chat with admin:

| Method | URL |
| -------- | ----- |
| `PUT` | `/api/customer/chat/create-channel` |
| `PUT` | `/api/customer/chat/send-message` |
| `GET` | `/api/customer/chat/conversation` |
| `GET` | `/api/customer/chat/channel-list` |
| `GET` | `/api/customer/chat/find-channel` |

These need trip-related fields (e.g. `trip_id`, `to`).

---

## Admin web (dashboard)

Open: `https://drivoeg.com/admin/chatting?chat_with=customer`

| Method | Path | Notes |
| -------- | ------ | -------- |
| `GET` | `/admin/chatting?chat_with=customer` | Customers tab |
| `GET` | `/admin/chatting?chat_with=driver` | Drivers tab (existing) |
| `POST` | `/admin/create-channel-with-customer` | Body: `customerId`, `_token` |
| `GET` | `/admin/customer-conversation/{channelId}?customerId=...` | HTML conversation |
| `POST` | `/admin/send-message-to-customer` | `channelId`, `customerId`, `message`, files |
| `GET` | `/admin/search-customers-chat?search=&page=1` | Search + pagination |

Drivers endpoints unchanged (`create-channel-with-driver`, `send-message-to-driver`, …).

---

## Driver support chat (reference)

Same shape as customer, under `/api/driver/chat/`:

- `PUT create-channel-with-admin`
- `PUT send-message-to-admin`
- `PUT send-predefined-question-to-admin`
- `GET conversation`
- `GET channel-list`

---

## Flutter flow (customer support)

1. Login as customer → get Bearer token  
2. `PUT /api/customer/chat/create-channel-with-admin` → save `data.channel.id`  
3. `PUT /api/customer/chat/send-message-to-admin` with `channel_id` + `message`  
4. Poll or refresh with `GET /api/customer/chat/conversation?channel_id=...`  
5. Admin replies from `/admin/chatting?chat_with=customer` → customer gets FCM (`action: admin_message`) when available  

---

## Error notes

| Situation | Typical response |
| ----------- | ------------------ |
| Missing/invalid channel | `403` + `channel_not_found` style code |
| Not authenticated | `401` |
| User not participant of channel | `403` CHANNEL_NOT_FOUND |

---

## Postman

Import: `docs/postman/Customer_Admin_Chat.postman_collection.json`

Set collection variables:

- `base_url` → `https://drivoeg.com`
- `customer_token` → real customer API token
- `channel_id` → filled after “Create Channel With Admin”
