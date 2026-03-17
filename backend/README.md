# AssistBridge Backend

Spring Boot API server for AssistBridge platform.

## Requirements

- Java 17+
- MongoDB
- Maven

## Setup

1. Install MongoDB and start the service
2. Copy `firebase-service-account.json.example` to `firebase-service-account.json` and add your Firebase credentials
3. Update `application.yml` with your configuration

## Run

```bash
mvn spring-boot:run
```

## API Endpoints

### Authentication
- `POST /api/auth/send-otp` - Send OTP to phone
- `POST /api/auth/verify-otp` - Verify OTP and login

### User
- `GET /api/users/me` - Get current user
- `PUT /api/users/me` - Update profile
- `PUT /api/users/me/location` - Update location

### Requests (Visually Impaired Users)
- `POST /api/requests` - Create help request
- `GET /api/requests` - Get my requests
- `GET /api/requests/{id}` - Get request details
- `PUT /api/requests/{id}/cancel` - Cancel request
- `POST /api/requests/{id}/rate` - Rate completed request

### Volunteer
- `GET /api/volunteer/requests` - Get assigned requests
- `GET /api/volunteer/requests/active` - Get active requests
- `PUT /api/volunteer/requests/{id}/accept` - Accept request
- `PUT /api/volunteer/requests/{id}/complete` - Complete request

### Admin
- `GET /api/admin/dashboard` - Get dashboard stats
- `GET /api/admin/requests` - Get all requests
- `GET /api/admin/requests/pending` - Get pending requests
- `POST /api/admin/assign` - Assign volunteer to request
- `GET /api/admin/users` - Get all users
- `GET /api/admin/volunteers` - Get all volunteers
- `GET /api/admin/volunteers/active` - Get active volunteers

### Notifications
- `GET /api/notifications` - Get all notifications
- `GET /api/notifications/unread` - Get unread notifications
- `GET /api/notifications/unread/count` - Get unread count
- `PUT /api/notifications/{id}/read` - Mark as read
- `PUT /api/notifications/read-all` - Mark all as read
