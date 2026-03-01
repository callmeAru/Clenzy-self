/// Backend API base URL - use for auth, admin, and all REST calls
const String apiBaseUrl = "https://clenzy-self-production-1715.up.railway.app/api";

/// Same as apiBaseUrl - for services that expect API_URL
const String API_URL = apiBaseUrl;

/// WebSocket base URL (append /{userId}?token=...) - use wss when backend uses https
String get wsUrl =>
    apiBaseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://') + '/ws';